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
    unless @snippetService?
      atom.notifications.addInfo(
        "Still waiting for the snippets service to activate..."
      )
      return

    te = atom.workspace.getActiveTextEditor()
    range = te.getSelectedBufferRange()
    text = te.getTextInBufferRange(range)
    text = text.replace(/\\/g, "\\\\")

    te.transact =>
      te.setTextInBufferRange(range, "")

      snippet = "\\\\$1cmd\\{#{text}\\}"
      # This is a HACK around current snippet limitations
      # Also note that we cannot trigger jumping to the end with $0
      cmd_range = [[range.start.row, range.start.column+1], [range.start.row, range.start.column+4]]
      @snippetService.insertSnippet(snippet)
      te.setSelectedBufferRange(cmd_range)

  wrapInEnvironment: ->

    # In case we haven't gotten the snippets service yet
    unless @snippetService?
      atom.notifications.addInfo(
        "Still waiting for the snippets service to activate..."
      )
      return

    te = atom.workspace.getActiveTextEditor()
    range = te.getSelectedBufferRange()
    text = te.getTextInBufferRange(range)
    text = text.replace(/\\/g, "\\\\")

    te.transact =>
      te.setTextInBufferRange(range, "")

      snippet = "\\\\begin\{$1env\}\n#{text}\n\\\\end\{$1env\}"
      # This is a HACK around current snippet limitations
      cmd_range_begin = [[range.start.row, range.start.column+7], [range.start.row, range.start.column+10]]
      nlines = text.split('\n').length
      cmd_range_end = [[range.start.row+nlines+1, range.start.column+5], [range.start.row+nlines+1, range.start.column+8]]
      @snippetService.insertSnippet(snippet)
      te.setSelectedBufferRange(cmd_range_begin)
      te.addSelectionForBufferRange(cmd_range_end)



  insertCmdEnv: (what) ->

    max_length = 100 # Maximum length of LaTeX command (should be enough!)

    unless @snippetService?
      atom.notifications.addInfo(
        "Still waiting for the snippets service to activate..."
      )
      return

    te = atom.workspace.getActiveTextEditor()

    # Using Atom's API:
    te.selectToBeginningOfWord()
    range = te.getSelectedBufferRange()
    arg = te.getTextInBufferRange(range)
    te.setSelectedBufferRange(range, '')

    if arg
      snippet = switch what
        when "command"
          "\\\\#{arg}\\{$1\\}$0"
        when "environment"
          "\\\\begin\{#{arg}\}\n$1\n\\\\end\{#{arg}\}$0"
      @snippetService.insertSnippet(snippet)


  wrapIn: (cmd) ->

    unless @snippetService?
      atom.notifications.addInfo(
        "Still waiting for the snippets service to activate..."
      )
      return

    te = atom.workspace.getActiveTextEditor()
    range = te.getSelectedBufferRange()
    text = te.getTextInBufferRange(range)
    text = text.replace(/\\/g, "\\\\")

    # Use snippets to easily remove selection, move cursor at end
    # (but only if there is some text)
    if text
      snippet = "\\\\#{cmd}\\{#{text}\\}$0"
    else
      snippet = "\\\\#{cmd}\\{$1\\}$0"
    @snippetService.insertSnippet(snippet)


  closeEnvironment: ->

    begin_rx = /\\(begin|end)\{([^\}]*)\}/

    te = atom.workspace.getActiveTextEditor()
    cursor = te.getCursorBufferPosition()

    found = false
    # TODO make this smarter: look for UNOPENED environments from beginning
    # NOTE: remember that the callback param is an OBJECT!
    te.backwardsScanInBufferRange begin_rx, [[0,0],cursor], ({match, matchText, range, stop, replace}) =>
      console.log(match)
      console.log(stop)
      # We only process one match, the first
      if match[1] == 'begin'
        te.insertText("\\end{#{match[2]}}\n")
        found = true
      # otherwise, match[1] == 'end', and we do nothing
      # When we first match, stop, so we don't get any further matches
      stop()

    if !found
      atom.notifications.addError "Could not find unmatched \\begin"

  # Handle dollar-sign matching
  # If there is a $ *after* the cursor, just move past it.
  # If there is no $ after, and no $ before, add $[cursor]$
  # Sane $$...$$ handling
  # Add space between $ $ so highlighting doesn't go crazy
  # Also handle selectioj

  dollarSign: ->

    te = atom.workspace.getActiveTextEditor()

    # First, check if there is a selection, and if so, add $..$ around it
    if text =  te.getSelectedText()
      text = text.replace(/\\/g, "\\\\")
      range = te.getSelectedBufferRange()
      te.setSelectedBufferRange(range, '')
      @snippetService.insertSnippet("\$#{text}\$")
      return

    cursor = te.getCursorBufferPosition()
    text = te.getTextInBufferRange([[cursor.row,0],[cursor.row,cursor.column+1]])

    pos = cursor.column

    # if cursor followed by $ or $$, skip themm
    if text[pos]? && text[pos] == '$'
      te.moveRight()
      if text[pos+1]? && text[pos+1] == '$'
        te.moveRight()
      return

    # Here cursor is NOT followed by $. Then insert as needed
    if (pos==0) || (pos>0) && !text[pos-1].match(/[a-zA-Z0-9\$\\]/)
      snippet = "\$${1: }\$"
      @snippetService.insertSnippet(snippet)
      #te.addSelectionForBufferRange([[cursor.row,pos+1],[cursor.row, pos+2]])
    else
      te.insertText('$')


  # Add matched quotes

  quotes: (left, right, ch) ->

    te = atom.workspace.getActiveTextEditor()

    # First, check if there is a selection, and if so, add quotes around it
    if text =  te.getSelectedText()
      text = text.replace(/\\/g, "\\\\")
      range = te.getSelectedBufferRange()
      te.setSelectedBufferRange(range, '')
      # Use snippet to leave selection on (same as ST)
      @snippetService.insertSnippet("#{left}${1:#{text}}#{right}")
      return

    # Ensure there is no character preceding the quote

    cursor = te.getCursorBufferPosition()
    text = te.getTextInBufferRange([[cursor.row,0],[cursor.row,cursor.column]])

    if text[cursor.column-1]? and
        !text[cursor.column-1].match(/\s/) and
        text[cursor.column-1] != left
      te.insertText(ch)
      return

    snippet = "#{left}$0#{right}"
    @snippetService.insertSnippet(snippet)
