fs = require 'fs'

texDirectivePattern = /%\s*!(?:T|t)(?:E|e)(?:X|x)\s+([\w-]+)\s*=\s*(.*?)\s*$/
latexCommandPattern = /\\[a-zA-Z]+\*?(?:\[[^\]]+\])*\{[^\}]+\}/

###
Parses a TextEditor or file for any %!TEX directives

returns an an object whose own properties are the directive name
(lower-cased) and whose value is the value after the = sign.

parameters:
  editorOrPath    - either a TextEditor or path to a file to parse

optional parameters:
  multiValues     - a list of directives to allow to have multiple values
                    if not included in the list only the first encountered
                    value is retained
  keyMaps         - an object mapping from a directive name encounted to the
                    directive name returned. intented to allow directives to
                    be renamed (e.g. ts-program -> program)
  onlyFor         - a list of the diretcives we are interested in to minimize
                    the size of the returned object. if only a single value is
                    present and no multiValues are specified, this will exit
                    once a match is found
###
module.exports = parse_tex_directives =
  (editorOrPath, {multiValues, keyMaps, onlyFor} = {}) ->
    # default values and coerce to correct type if possible
    multiValues ?= []
    multiValues = [].concat(multiValues) if typeof multiValues is 'string'

    keyMaps ?= {}
    keyMaps = {} if typeof keyMaps isnt 'object'

    onlyFor ?= []
    onlyFor = [].concat(onlyFor) if typeof onlyFor is 'string'

    result = {} # new Object

    lines =
      if typeof(editorOrPath) is 'string'
        # we assume that a string is the path to a file to read
        fs.readFileSync(editorOrPath, 'utf8').toString().split('\n')
      else
        editorOrPath.getBuffer().getLines()

    hasOnlyFor =
      try
        onlyFor? and onlyFor.length > 0
      catch
        # onlyFor is some non-array-like type
        false

    breakOnFirst = hasOnlyFor and onlyFor.length is 1 and (
      not multiValues? or onlyFor[0] not in multiValues
    )

    for line in lines
      break if line.match latexCommandPattern
      match = line.match texDirectivePattern
      if match?
        key = match[1].toLowerCase()
        if key of keyMaps
          key = keyMaps[key]

        if hasOnlyFor and key not in onlyFor
          continue

        if key in multiValues
          if key of result
            result[key].push match[2]
          else
            result[key] = [match[2]]
        else
          if key not of result
            result[key] = match[2]

          break if breakOnFirst

    return result
