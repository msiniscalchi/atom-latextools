module.exports =
class LTConsoleView
  constructor: (serializedState) ->

    console.log("Constructing LTConsoleView")

    # Try to figure out font size, etc.
    font = atom.config.get("editor.fontFamily")
    font = "Lucida Console, Consolas, monospace" if font == ""
    fontSize = Math.round(atom.config.get("editor.fontSize")*0.9)
    console.log(font,fontSize)

    # panel is the entire panel
    # element is just the content part
    @panel = document.createElement('div')
    @panel.classList.add('inset-panel')
    panelHeading = document.createElement('div')
    panelHeading.classList.add('panel-heading')
    panelHeading.innerHTML = "<strong>LaTeXTools Console</strong>"
    @panel.appendChild(panelHeading)
    @element = document.createElement('div')
    @element.classList.add('panel-body','padded')
    @element.style.fontSize = "125%"
    @element.style.height = "#{(5+1)*fontSize*1.25}px"
    @element.style.overflow = "scroll"
    @panel.appendChild(@element)
    # @element.style.fontFamily = font
    # @element.style.fontSize = "#{fontSize}px"

    # return something meaningful
    true

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @panel.remove()

  getElement: ->
    @element

  getPanel: ->
    @panel
