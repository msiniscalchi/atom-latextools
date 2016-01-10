fs = require 'fs'

texDirectivePattern = /%\s*!(?:T|t)(?:E|e)(?:X|x)\s+([\w-]+)\s*=\s*(.*?)\s*$/
latexCommandPattern = /\\[a-zA-Z]+\*?(?:\[[^\]]+\])*\{[^\}]+\}/

module.exports = parse_tex_directives =
  (editorOrPath, {multiValues, keyMaps} = {}) ->
    multiValues ?= []
    keyMaps     ?= {}
    result      = new Object

    lines =
      if typeof(editorOrPath) is 'string'
        # we assume that a string is the path to a file to read
        fs.readFileSync(editorOrPath, 'utf8').toString().split('\n')
      else
        editorOrPath.getBuffer().getLines()


    for line in lines
      break if line.match latexCommandPattern
      match = line.match texDirectivePattern
      if match?
        key = match[1].toLowerCase()
        if key of keyMaps
          key = keyMaps[key]

        if key in multiValues
          if key of result
            result[key].push match[2]
          else
            result[key] = [match[2]]
        else
          result[key] = match[2]
    return result
