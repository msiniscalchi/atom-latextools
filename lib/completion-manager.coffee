{LTool,get_tex_root,find_in_files} = require './ltutils'
LTSelectListView = require './ltselectlist-view'
#get_ref_completions = require './get-ref-completions'
#get_bib_completions = require './get-bib-completions'
path = require 'path'
fs = require 'fs'

module.exports =

class CompletionManager extends LTool
  sel_view: null
  sel_panel: null

  constructor: (@ltconsole) ->
    super
    @sel_view = new LTSelectListView


  ref_complete: ->

    te = atom.workspace.getActiveTextEditor()

    fname = get_tex_root(te.getPath())

    parsed_fname = path.parse(fname)

    filedir = parsed_fname.dir
    filebase = parsed_fname.base  # name only includes the name (no dir, no ext)

    labels = find_in_files(filedir, filebase, /\\label\{([^\}]+)\}/g, [])

    @sel_view.setItems(labels)
    @sel_view.start (item) =>
      alert("#{item} was chosen")

  destroy: ->
    @sel_panel.destroy()
