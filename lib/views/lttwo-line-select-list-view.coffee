LTSelectListView = require './ltselect-list-view'

module.exports =
class LTTwoLineSelectList extends LTSelectListView
  viewForItem: (item) ->
    """
    <li class='two lines'>
      <div class='primary-line'>#{item.primary}</div>
      <div class='secondary-line'>#{item.secondary}</div>
    </li>
    """

  getFilterKey: ->
    'primary'

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
