{CompositeDisposable} = require 'atom'
fs = require 'fs'
path = require 'path'

# Base class for all tools
# Constructor only copies the console to an instance variable
# Also create instance (?) variable for viewer, so it can be called from
# any other LTool, including the builder

module.exports.LTool =

class LTool
  viewer: null

  constructor: (@ltConsole) ->


# Utility functions

# Find tex root by checking %!TEX line
# TODO add support for project files
# TODO add support for configurable extensions

# In: current tex file; Out: file to be compiled
module.exports.get_tex_root = (texFile) ->

  root_rx = /// ^         # at beginning of Line
            %\s*!TEX      # %!TEX, with spaces between % and !
            \s+           # at least one space after TEX
            root\s*=\s*   # then root=, possibly with spaces before / after =
            (.*\.tex)     # then file name.tex
            $ ///i         # then EOL; match case-insensitiive

  root = texFile

  lines = fs.readFileSync(texFile, 'utf-8').split('\n')

  i = 0
  while i < lines.length
    line = lines[i]
    break if line[0] != '%'
    root_match = root_rx.exec(line)
    if root_match
      root = root_match[1]
      console.log(root_match)
      # Now handle relative paths
      if !path.isAbsolute(root)
        dir = path.dirname(texFile)
        root = path.join(dir, root) # already normalized, unlike Python
      else
        root = path.normalize(root)
    i++

  return root
