{Disposable} = require 'atom'
path = require 'path'


module.exports =
class LTConsoleMessageView extends Disposable
  constructor: ({message, isHtml, classes, @line, @file, @dir}) ->
    @element = document.createElement 'div'
    @element.classList.add classes...

    if isHtml
      @element.innerHTML = message
    else
      @element.textContent = message

    if @file?
      @line = 1 unless @line?
      @abspath = path.join(@dir,@file)
      @element.style.cursor = 'pointer'
      @element.addEventListener 'click', @gotoMessage

  getElement: -> @element

  gotoMessage: (e) =>
    e?.stopPropagation()
    console.log("gotoMessage")
    console.log @file, @abspath, @line - 1
    atom.workspace.open @abspath, initialLine: @line - 1

  dispose: ->
    @element.removeEventListener('click', @gotoMessage) if @file?
    @element.remove()
