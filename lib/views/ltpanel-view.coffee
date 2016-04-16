module.exports =
class LTPanelView
  constructor: ->
    @isAttached = false

  # public API
  attach: ->
    return if @isAttached
    @panel = @createPanel()
    @isAttached = true

  show: ->
    @panel?.show()

  hide: (e) =>
    e?.stopPropagation()
    @panel?.hide()

  dispose: ->
    # kill the panel
    @panel?.destroy()

  # API for subclass
  createPanel: ->
    throw new Error 'Subclass must implement createPanel() method'
