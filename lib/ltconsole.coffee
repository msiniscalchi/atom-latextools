LTConsoleView = require './ltconsole-view'
{CompositeDisposable} = require 'atom'

module.exports =
class LTConsole
  ltConsoleView: null
  bottomPanel: null
  subscriptions: null

  constructor: (state) ->
    console.log("constructing LTConsole")
    if state == undefined
      state = {}
    @ltConsoleView = new LTConsoleView(state.ltConsoleViewState)
    @bottomPanel = atom.workspace.addBottomPanel(item: @ltConsoleView.getPanel(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    # Not sure I need it here, but let's play it safe
    @subscriptions = new CompositeDisposable

  destroy: ->
    @bottomPanel.destroy()
    @subscriptions.dispose()
    @ltConsoleView.destroy()

  serialize: ->
    ltConsoleViewState: @ltConsoleView.serialize()

  # Public API:

  show: ->
    console.log("ltconsole.show()")
    @bottomPanel.show()

  hide: ->
    console.log("ltconsole.hide()")
    @bottomPanel.hide()

  isVisible: ->
    @bottomPanel.isVisible()

  toggle_log: ->
    if @isVisible()
      @hide()
    else
      @show()

  addContent: (t, br=true, is_html=false, cb=undefined) ->
    el_span = document.createElement('span')
    el_br = document.createElement('br')
    el_span.onclick = cb if cb
    if is_html
      el_span.innerHTML = t
    else
      el_text = document.createTextNode(t)
      el_span.appendChild(el_text)
      el_text = null
    el_span.appendChild(el_br) if br
    @ltConsoleView.getElement().appendChild(el_span)
    # scroll to bottom of content
    @ltConsoleView.getElement().scrollTop = @ltConsoleView.getElement().scrollHeight

  clear: ->
    @ltConsoleView.getElement().innerHTML = ""

  add_log: ->
    if @bottomPanel.isVisible()
      for i in [1..10]
        do (i) =>
          @addContent("Line #{i}", br=true, is_html=false, cb= =>
            console.log("Line #{i} clicked"))
