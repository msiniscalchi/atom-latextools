{CompositeDisposable} = require 'atom'
path = require 'path'
LTConsoleView = require './views/ltconsole-view'
LTConsoleMessageView = require './views/ltconsole-message-view'

disposable = undefined

# terrible hack to use the editor font
setupLogCss = ->
  # these seem to be the defaults...
  FONT_DEFAULT = "Menlo, Consolas, 'DejaVu Sans Mono', monospace"
  FONT_SIZE_DEFAULT = '14px'

  for sheet in document.styleSheets
    if sheet.ownerNode.sourcePath? and
        path.basename(sheet.ownerNode.sourcePath) is 'latextools.less'

      font = atom.config.get 'editor.fontFamily' or FONT_DEFAULT
      fontSize = atom.config.get 'editor.fontSize' or FONT_SIZE_DEFAULT
      createLogRule sheet, font, fontSize

      disposable.add atom.config.observe 'editor.fontFamily', (value) ->
        font = value or FONT_DEFAULT
        createLogRule sheet, font, fontSize

      disposable.add atom.config.observe 'editor.fontSize', (value) ->
        fontSize = value or FONT_SIZE_DEFAULT
        createLogRule sheet, font, fontSize
      break

createLogRule = (sheet, font, fontSize) ->
  index = sheet.cssRules.length
  for i in [0...index]
    rule = sheet.cssRules[i]
    if rule.selectorText is '.latextools-console-message'
      sheet.deleteRule i
      index = i
      break

  # style for actual message
  sheet.insertRule(
    ".latextools-console-message { font-family: #{font}; font-size: #{fontSize}; }",
    index
  )

module.exports =
class LTConsole
  constructor: (state) ->
    disposable = new CompositeDisposable
    setupLogCss()

    unless state?.messages?
      @messages = new LTConsoleView
        title: '<strong>LaTeXTools Console</strong>'
        isHtml: true
    else
      @messages = new LTConsoleView state.messages

    # close the console if we switch to a non-LaTeX view
    disposable.add atom.workspace.onDidStopChangingActivePaneItem (item) =>
      for pane in atom.workspace.getPanes()
        activeItem = pane.getActiveItem()
        if activeItem? and activeItem.getGrammar?()?.scopeName is 'text.tex.latex'
          return
      # no visible LaTeX editor in current window
      @messages.hide()

  destroy: ->
    @messages.dispose()
    disposable.dispose()

  serialize: ->
    messages: @messages.serialize()

  # Public API:
  show: ->
    @messages.attach()
    @messages.show()

  hide: ->
    @messages.hide()

  toggle: ->
    @messages.toggle()

  addContent: (message, {file, dir, line, is_html, level} = {}) ->
    is_html = false unless is_html?
    classes = ["latextools-console-message"]
    # level should be "error", "warning", or "info"
    classes.push("text-#{level}") if level?

    message = new LTConsoleMessageView
      message: message
      isHtml: is_html
      classes: classes
      line: line
      file: file
      dir: dir

    @messages.add message

  clear: ->
    @messages.clear()
