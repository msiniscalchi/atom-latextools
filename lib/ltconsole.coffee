{MessagePanelView, LineMessageView, PlainMessageView} =
  require 'atom-message-panel'
{CompositeDisposable} = require 'atom'
path = require 'path'

disposable = new CompositeDisposable

# terrible hack to use the editor font
setupLogCss = ->
  # these seem to be the defaults...
  FONT_DEFAULT = "Menlo, Consolas, 'DejaVu Sans Mono', monospace"
  FONT_SIZE_DEFAULT = '12px'

  for i in [0...document.styleSheets.length]
    sheet = document.styleSheets[i]
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

createLogRule = (sheet, font, fontSize) ->
  index = 0
  for i in [0...sheet.cssRules.length]
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
    setupLogCss()
    @messages = new MessagePanelView
      title: '<strong>LaTeXTools Console</strong>'
      rawTitle: true
      closeMethod: 'hide'
      autoScroll: true
      className: 'latextools-console'

    @messages.setSummary summary: ''

  # Public API:
  show: ->
    @messages.attach()

  hide: ->
    @messages.hide()

  toggle: ->
    @messages.toggle()

  addContent: (message, {file, line, is_html, level} = {}) ->
    is_html = false unless is_html?
    # basically level should be "error" or "warning"
    className = "latextools-console-message"
    className += " text-#{level}" if level?

    message = new PlainMessageView
      message: message
      raw: is_html,
      className: className

    if file?
      line = 1 unless line?
      message.element.onclick = ->
        atom.workspace.open file, initialLine: line - 1

    @messages.add message

  clear: ->
    @messages.clear()
