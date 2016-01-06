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
      # Now handle relative paths
      if !path.isAbsolute(root)
        dir = path.dirname(texFile)
        root = path.join(dir, root) # already normalized, unlike Python
      else
        root = path.normalize(root)
    i++

  return root

# Find all matches of a regex starting from a master file
# and working our way through all included files
#
# Based on LaTeXTools' find_labels_in_files
module.exports.find_in_files = (rootdir, src, rx) ->

  include_rx = /\\(?:input|include)\{([^\{\}]+)\}/g

  # We need a new RegExp object for every recursion!
  # Hence, we must pass it as a string
  #rx = new RegExp(rx_string, "g")
  # Hmm... apparently not! Good!

  # Deal with the possibility of a file without an extension
  # (always the case with \include)

  tex_exts = atom.config.get('latextools.texFileExtensions')
  if path.extname(src) in tex_exts
    tex_src = src
  else
    console.log("Need to find extension for #{src}")
    not_found = true
    i = 0 # old-style looping
    while not_found && i < tex_exts.length
      tex_src = src + tex_exts[i] # ext contains a dot
      i++
      try
        s = fs.statSync(path.join(rootdir, tex_src))
      catch e
        continue
      not_found = false if s.isFile()
    if not_found
      alert("Could not find #{src}")
      return null

  file_path = path.join(rootdir, tex_src) # automatically normalizes
  console.log("find_in_files: searching #{file_path}")

  try
    src_content = fs.readFileSync(file_path, 'utf-8')
  catch e
    alert("Could not read #{file_path}; encoding issues?")
    return null


  # TODO get rid of commented out lines

  # Look for matches in the current file
  results = []
  while (r = rx.exec(src_content)) != null
    console.log("found " + r[1] + " in " + file_path)
    results.push(r[1])

  # Now look for included files and recurse into them
  while (next_file_match = include_rx.exec(src_content)) != null
    new_results = module.exports.find_in_files(rootdir, next_file_match[1], rx)
    results = results.concat(new_results)

  return results
