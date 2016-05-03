{CompositeDisposable, Disposable} = require 'atom'
LTPanelView = require './ltpanel-view'

fuzzyFilter = null # defer

module.exports =
class LTSelectListView extends LTPanelView
  constructor: ->
    super

    # create DOM
    @element = document.createElement 'div'
    @element.classList.add 'select-list', 'overlay', 'from-top'

    # message basically for "no items"
    @error = document.createElement 'div'
    @error.classList.add 'error-message'
    @element.appendChild @error

    # filter editor box
    @filterEditor = document.createElement 'atom-text-editor'
    @filterEditor.classList.add 'editor'
    @filterEditor.setAttribute 'mini', true
    @element.appendChild @filterEditor

    @list = document.createElement 'ol'
    @list.classList.add 'list-group'
    @element.appendChild @list

    # Atom event bindings
    @disposable = new CompositeDisposable
    @disposable.add @filterEditor.getModel().getBuffer().onDidChange =>
      @scheduleFilterUpdate()

    @disposable.add atom.commands.add @element,
      'core:move-up': (e) =>
        @selectPreviousItem()
        e.stopPropagation()

      'core:move-down': (e) =>
        @selectNextItem()
        e.stopPropagation()

      'core:move-to-top': (e) =>
        @selectItem(@list.querySelector('li:first-of-type'))
        e.stopPropagation()

      'core:move-to-bottom': (e) =>
        @selectItem(@list.querySelector('li:last-of-type'))
        e.stopPropagation()

      'core:confirm': (e) =>
        @confirmSelection()
        e.stopPropagation()

      'core:cancel': (e) =>
        @cancel()
        e.stopPropagation()

    # DOM event handlers
    @disposable.add(do =>
      callback = ({target}) =>
        false if target is @list[0]
      @list.addEventListener 'mousedown', callback

      new Disposable ->
        @list.removeEventListener 'mousedown', callback
    )

    @disposable.add(do =>
      callback = (e) =>
        if e.target.closest('ol.list-group') isnt @list or e.target is @list
          return
        @selectItem e.target.closest('li')
        e.stopPropagation()
        false

      document.addEventListener 'mousedown', callback

      new Disposable ->
        document.removeEventListener 'mousedown', callback
    )

    @disposable.add(do =>
      callback = (e) =>
        if e.target.closest('ol.list-group') isnt @list
          @cancel() if e.target isnt @list
          return
        if e.target.closest('li').classList.contains('selected')
          @confirmSelection()
        e.stopPropagation()
        false

      document.addEventListener 'mouseup', callback

      new Disposable ->
        document.removeEventListener 'mouseup', callback
    )

    # state
    @cancelling = false
    @scheduledTimeout = null
    @listItems = []

    @attach()
    @hide()

  # - public API
  # items
  getSelectedItem: ->
    data = @getSelectedItemView()?.getAttribute('data-select-list-item')
    JSON.parse(data) if data

  setItems: (listItems) ->
    @clear()
    @listItems = listItems
    @populateList()

  # - subclass API
  confirmed: (item) ->
    throw new Error 'Subclass must implement a confirmed(item) method'

  cancelled: ->

  viewForItem: (item) ->
    throw new Error 'Subclass must implement a viewForItem(item) method'

  # filters
  getFilterKey: ->

  # - internal API
  cancel: ->
    @clear()
    @cancelling = true
    @cancelled()
    clearTimeout(@scheduledTimeout)

  clear: ->
    @listItems = []
    @list.innerHTML = null

  confirmSelection: ->
    item = @getSelectedItem()
    if item?
      @confirmed item
    else
      @cancel()

  createPanel: ->
    atom.workspace.addModalPanel
      item: @element
      visible: true

  dispose: ->
    @disposable.dispose()
    super

  populateList: ->
    return unless @listItems?
    @error.textContent = ''

    # filter the list
    filterQuery = @filterEditor.getModel().getText()
    if filterQuery.length
      fuzzyFilter ?= require('fuzzaldrin').filter
      filteredItems = fuzzyFilter(@listItems, filterQuery, key: @getFilterKey())
    else
      filteredItems = @listItems

    # build the DOM objects
    @list.innerHTML = null
    if filteredItems.length
      for item in filteredItems
        itemView = @viewForItem(item)
        # handle string templates
        # FIXME is DOMParser more efficient?
        if typeof itemView is "string"
          fake = document.createElement('div')
          fake.innerHTML = itemView
          itemView = fake.firstChild

        itemView.setAttribute('data-select-list-item', JSON.stringify(item))
        @list.appendChild(itemView)

      @selectItem(@list.querySelector('li:first-of-type'))
    else
      @error.textContent = 'No matches found'

  getSelectedItemView: ->
    @list.querySelector('.selected')

  selectItem: (view) ->
    return unless view?
    @getSelectedItemView()?.classList.remove 'selected'
    view.classList.add 'selected'
    @scrollToItem(view)

  selectNextItem: ->
    view = @getSelectedItemView().nextElementSibling
    # select the first item of the list if we reached the end
    view = @list.querySelector('li') unless view?
    @selectItem(view)

  selectPreviousItem: ->
    view = @getSelectedItemView().previousElementSibling
    # select the last item of the list if we reached the first
    view = @list.querySelector('li:last-of-type') unless view?
    @selectItem(view)

  scrollToItem: (view) ->
    boundingClientRect = view.getBoundingClientRect()
    scrollTop = @list.scrollTop
    scrollBottom = scrollTop + @list.clientHeight
    desiredTop = boundingClientRect.top + scrollTop - view.clientHeight
    desiredBottom = boundingClientRect.bottom + scrollTop

    @list.scrollTop =
      if desiredTop < scrollTop
        Math.max(desiredTop, 0)
      else if desiredBottom > scrollBottom
        if desiredBottom < @list.scrollHeight
          desiredBottom - @list.clientHeight - view.scrollHeight
        else
          @list.scrollTop = @list.scrollHeight
      else
        @list.scrollTop

  scheduleFilterUpdate: ->
    clearTimeout(@scheduledTimeout)
    @scheduleTimeout = setTimeout((=> @populateList() if @isAttached), 50)

  show: (te) ->
    if te?
      @previouslyFocusedElement = atom.views.getView(te)
    super
    # Erase old text in filter editor
    # TODO: set programmatically? Maybe via API?
    @filterEditor.getModel().setText("")
    @filterEditor.focus()

  hide: ->
    super
    @previouslyFocusedElement?.focus?()
