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

  start: (@callback) ->
    @show()

  getPanel: ->
    return @panel

  destroy: ->
    @dispose()
