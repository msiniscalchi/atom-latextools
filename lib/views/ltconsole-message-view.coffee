{Disposable} = require 'atom'

module.exports =
class LTConsoleMessageView extends Disposable
  constructor: ({message, isHtml, classes, @line, @file}) ->
    @element = document.createElement 'div'
    @element.classList.add classes...

    if isHtml
      @element.innerHTML = message
    else
      @element.textContent = message

    if @file?
      @line = 1 unless @line?
      @element.style.cursor = 'pointer'
      @element.addEventListener 'click', @gotoMessage

  getElement: -> @element

  gotoMessage: (e) =>
    e?.stopPropagation()
    console.log @file, @line - 1
    atom.workspace.open @file, initialLine: @line - 1

  dispose: ->
    @element.removeEventListener('click', @gotoMessage) if @file?
    @element.remove()
