{CompositeDisposable} = require 'atom'

module.exports =
class ViewerRegistry
  constructor: ->
    @viewers = {}

  clear: ->
    @viewers = {}

  add: (names, cls) ->
    names = [names] unless Array.isArray names

    for name in names
      @viewers[name] = cls

  get: (name) ->
    return @viewers[name] if name of @viewers
    undefined
