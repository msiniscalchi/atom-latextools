{LTool,get_tex_root} = require './ltutils'

module.exports =

class SnippetManager extends LTool
  snippetService: null

  constructor: ->
    super
    console.log("Created SnippetManager")

  setService: (service) ->
    console.log("Set snippet service")
    console.log(service)
    @snippetService = service

  wrapInCommand: ->

    # In case we haven't gotten the snippets service yet
    if !@snippetService
      alert("Still waiting for the snippets service to activate...")
      return

    te = atom.workspace.getActiveTextEditor()
    range = te.getSelectedBufferRange()
    text = te.getTextInBufferRange(range)

    te.setTextInBufferRange(range, "")

    snippet = "\\\\$1cmd\{#{text}\}"
    # This is a HACK around current snippet limitations
    # Also note that we cannot trigger jumping to the end with $0
    cmd_range = [[range.start.row, range.start.column+1], [range.start.row, range.start.column+4]]
    @snippetService.insertSnippet(snippet)
    te.setSelectedBufferRange(cmd_range)

  wrapInEnvironment: ->

    # In case we haven't gotten the snippets service yet
    if !@snippetService
      alert("Still waiting for the snippets service to activate...")
      return

    te = atom.workspace.getActiveTextEditor()
    range = te.getSelectedBufferRange()
    text = te.getTextInBufferRange(range)

    te.setTextInBufferRange(range, "")

    snippet = "\\\\begin\{$1env\}\n#{text}\n\\\\end\{$1env\}"
    # This is a HACK around current snippet limitations
    cmd_range_begin = [[range.start.row, range.start.column+7], [range.start.row, range.start.column+10]]
    nlines = text.split('\n').length
    cmd_range_end = [[range.start.row+nlines+1, range.start.column+5], [range.start.row+nlines+1, range.start.column+8]]
    @snippetService.insertSnippet(snippet)
    te.setSelectedBufferRange(cmd_range_begin)
    te.addSelectionForBufferRange(cmd_range_end)


  wrapIn: (cmd) ->

    if !@snippetService
      alert("Still waiting for the snippets service to activate...")
      return

    te = atom.workspace.getActiveTextEditor()
    range = te.getSelectedBufferRange()
    text = te.getTextInBufferRange(range)

    # Use snippets to easily remove selection, move cursor at end
    snippet = "\\\\#{cmd}\\{#{text}\\}$0"
    @snippetService.insertSnippet(snippet)
