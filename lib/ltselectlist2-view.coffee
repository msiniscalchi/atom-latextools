{SelectListView} = require 'atom-space-pen-views'

module.exports =
class LTSelectList2View extends SelectListView
  callback: null

  initialize: ->
    super
    @addClass('overlay from-top')
    @panel = atom.workspace.addModalPanel(item: this)
    @panel.hide()

  viewForItem: (item) ->
    """
    <li class='two lines'>
      <div class='primary-line'>#{item.primary}</div>
      <div class='secondary-line'>#{item.secondary}</div>
    </li>
    """

  getFilterKey: ->
    'primary'


  confirmed: (item) ->
    @selected_item = item
    @restoreFocus()
    @panel.hide()
    @callback(item)

  # API unclear: cancel or cancelled?
  cancel: ->
    super
    @restoreFocus()
    @panel.hide()

  start: (@callback) ->
    @selected_item = null
    @panel.show()
    @storeFocusedElement()
    @focusFilterEditor()

  getPanel: ->
    return @panel

  destroy: ->
    @panel.remove()
    @panel.destroy()
