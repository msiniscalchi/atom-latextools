LTSelectListView = require './ltselect-list-view'

module.exports =
class LTSimpleSelectList extends LTSelectListView
  viewForItem: (item) ->
    "<li>#{item}</li>"

  confirmed: (item) ->
    @hide()
    @callback(item)

  cancelled: ->
    @hide()

  start: (te, @callback) ->
    @show(te)

  getPanel: ->
    return @panel

  destroy: ->
    @dispose()
