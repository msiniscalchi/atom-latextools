{LTool,get_tex_root,find_in_files} = require './ltutils'
LTSelectListView = require './ltselectlist-view'
LTSelectList2View = require './ltselectlist2-view'
#get_ref_completions = require './get-ref-completions'
#get_bib_completions = require './get-bib-completions'
path = require 'path'
fs = require 'fs'

module.exports =

class CompletionManager extends LTool
  sel_view: null
  sel2_view: null
  sel_panel: null

  constructor: (@ltconsole) ->
    super
    @sel_view = new LTSelectListView
    @sel2_view = new LTSelectList2View


  refComplete: ->

    te = atom.workspace.getActiveTextEditor()

    fname = get_tex_root(te.getPath())

    parsed_fname = path.parse(fname)

    filedir = parsed_fname.dir
    filebase = parsed_fname.base  # name only includes the name (no dir, no ext)

    labels = find_in_files(filedir, filebase, /\\label\{([^\}]+)\}/g)

    # TODO add partially specified label to search field
    @sel_view.setItems(labels)
    @sel_view.start (item) =>
      te.insertText(item)
      # see if we need to skip a brace
      pt = te.getCursorBufferPosition()
      ran = [[pt.row, pt.column], [pt.row, pt.column+1]]
      if te.getTextInBufferRange(ran) == '}'
        te.moveRight()


  refCompleteAuto: (te) ->

    max_length = 10 # max length of ref command, including backslash
    ref_rx = /\\(?:eq|page|v|V|auto|name|c|C|cpage)?ref\{/

    max = (a,b) ->
      if a > b then a else b

    current_point = te.getCursorBufferPosition()
    initial_point = [current_point.row, max(0,current_point.column - max_length)]
    range = [initial_point, current_point]
    # console.log(range)
    # console.log(te.getTextInBufferRange(range))

    te.backwardsScanInBufferRange ref_rx, range, ({match, stop}) =>
      console.log("found match")
      @refComplete()
      stop()


  citeComplete: ->

    # just a test for now
    items = [
      {"primary": "First Item", "secondary": "A cool item", "id":0},
      {"primary": "Second Item", "secondary": "An equally cool item", "id":1}
    ]

    @sel2_view.setItems(items)
    @sel2_view.start (item) =>
      alert(item["id"])

  destroy: ->
    @sel2_view.destroy()
    @sel_view.destroy()
