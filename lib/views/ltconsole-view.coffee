{CompositeDisposable} = require 'atom'
LTPanelView = require './ltpanel-view'

module.exports =
class LTConsoleView extends LTPanelView
  constructor: ({title, isHtml, height, collapsed} = {}) ->
    super
  
    # create DOM
    @element = document.createElement 'div'
    @element.classList.add 'latextools-console'

    # resizing handle
    @resizeHandler = document.createElement 'div'
    @resizeHandler.classList.add 'panel-resize-handle'
    @resizeHandler.addEventListener 'mousedown', @resizeStarted
    @element.appendChild @resizeHandler

    # heading
    @heading = document.createElement 'div'
    @heading.classList.add 'panel-heading'

    # title
    @headingTitle = document.createElement 'div'
    @headingTitle.classList.add 'heading-title', 'inline-block'
    @headingTitle.addEventListener 'click', @toggle
    @heading.appendChild @headingTitle

    # control buttons
    @headingButtons = document.createElement 'div'
    @headingButtons.classList.add 'heading-buttons', 'inline-block', 'pull-right'

    @toggleButton = document.createElement 'button'
    @toggleButton.classList.add 'btn', 'icon', 'icon-fold', 'inline-block-tight'
    @toggleButton.addEventListener 'click', @toggle
    @headingButtons.appendChild @toggleButton

    @trashButton = document.createElement 'button'
    @trashButton.classList.add 'btn', 'icon', 'icon-trashcan', 'inline-block-tight'
    @trashButton.addEventListener 'click', @clear
    @headingButtons.appendChild @trashButton

    @closeButton = document.createElement 'button'
    @closeButton.classList.add 'btn', 'icon', 'icon-x', 'inline-block-tight'
    @closeButton.addEventListener 'click', @hide
    @headingButtons.appendChild @closeButton

    @heading.appendChild @headingButtons

    @element.appendChild @heading
    # end heading

    # body
    @body = document.createElement 'div'
    @body.classList.add 'panel-body', 'padded', 'native-key-bindings'
    @body.setAttribute 'tabindex', -1
    @element.appendChild @body
    # end body
    # end DOM

    @messages = []

    if title?
      isHtml = false unless isHtml?
      @setTitle title, isHtml

    if height?
      @body.style.height = height
    else
      @body.style.height = '170px'

    @collapse() if collapsed? and collapsed

  # public API
  add: (message) ->
    @messages.push message
    @body.appendChild message.getElement()
    @body.scrollTop = @body.scrollHeight

  clear: (e) =>
    e?.stopPropagation()
    message?.dispose() for message in @messages
    @messages = []

  toggle: (e) =>
    e?.stopPropagation()

    if @body.style.display isnt 'none'
      @collapse()
    else
      @expand()

  collapse: ->
    @body.style.display = 'none'
    @resizeHandler.style.cursor = 'default'

  expand: ->
    @body.style.display = 'block'
    @resizeHandler.style.cursor = 'row-resize'

  setTitle: (title, isHtml = false) ->
    @title = title
    @isHtml = isHtml

    if isHtml
      @headingTitle.innerHTML = title
    else
      @headingTitle.textContent = title

  # event handlers
  resizeStarted: (e) =>
    e.stopPropagation()

    # i.e., if the console is collapsed
    return if @body.style.display is 'none'

    @startY = e.clientY
    # this is a bit hackish
    # getHeight returns a string potentially with units, but it's the most
    # accurate way of getting the body height, allowing that it may have been
    # adjusted elsewhere by CSS
    @initialHeight = parseInt @getHeight()

    document.addEventListener 'mousemove', @resizePanel
    document.addEventListener 'mouseup', @resizeStopped

  resizeStopped: (e) =>
    e.stopPropagation()
    document.removeEventListener 'mousemove', @resizePanel
    document.removeEventListener 'mouseup', @resizeStopped

  resizePanel: (e) =>
    e.stopPropagation()
    @body.style.height = "#{@initialHeight + @startY - e.clientY}px"

  # internal API
  createPanel: ->
    atom.workspace.addBottomPanel
      item: @element
      visible: true

  dispose: ->
    # dispose of messages
    @clear()
    # remove event handlers
    @resizeHandler.removeEventListener 'mousedown', @resizeStarted
    @headingTitle.removeEventListener 'click', @toggle
    @toggleButton.removeEventListener 'click', @toggle
    @closeButton.removeEventListener 'click', @hide
    super

  serialize: ->
    title: @title
    isHtml: @isHtml
    height: @getHeight()
    collapsed: @body.style.display is 'none'

  getHeight: ->
    document.defaultView.getComputedStyle(@body).height
