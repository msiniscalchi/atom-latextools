{LTool,get_tex_root} = require './ltutils'
{exec, execFile} = require 'child_process'
path = require 'path'

module.exports =

class Viewer extends LTool


  _jumpWindows: (texfile, pdffile, row, col) ->
    sumatra_cmd = atom.config.get("latextools.windows.sumatra")
    sumatra_args = [] # ["-reuse-instance"]

    if atom.config.get("latextools.forwardSync")
      sumatra_args = sumatra_args.concat(["-forward-search", '\"'+texfile+'\"', "#{row}"])

    sumatra_args.push('\"'+pdffile+'\"')

    command = sumatra_cmd + ' ' + sumatra_args.join(' ')
    @ltConsole.addContent("Executing " + command)

    exec command, {}, (err, stdout, stderr) =>
      if err > 1 # weirdness
        @ltConsole.addContent("ERROR #{err.code}: ", br=true)
        @ltConsole.addContent(line, br=true) for line in stderr.split('\n')




  _jumpDarwin: ->
    alert("Not implemented yet")

  _jumpLinux: ->
    alert("Not implemented yet")

  _jumpToPdf: (texfile, pdffile, row, col=1) ->

    # TODO make modular, but for now...
    switch process.platform
      when "darwin" then @_jumpDarwin(texfile, pdffile, row, col)
      when "win32" then @_jumpWindows(texfile, pdffile, row, col)
      when "linux" then @_jumpLinux(texfile, pdffile, row, col)
      else
        alert("Sorry, no viewer for the current platform")

  jumpToPdf: ->
    te = atom.workspace.getActiveTextEditor()
    pt = te.getCursorBufferPosition()
    row = pt.row + 1 # Atom's rows/cols are 0-based, synctex's are 1-based
    col = pt.column + 1

    # this is the file currently being edited, which is where the user wants to jump to
    current_file = te.getPath()
    # it need not be the master file, so we look for that, too
    master_file = get_tex_root(current_file)

    parsed_master = path.parse(master_file)
    parsed_current = path.parse(current_file)

    tex_exts = atom.config.get("latextools.texFileExtensions")
    if parsed_master.ext in tex_exts && parsed_current.ext in tex_exts
      master_path_no_ext = path.join(parsed_master.dir, parsed_master.name)
      @ltConsole.addContent("Jump to #{row},#{col}")
      @_jumpToPdf(current_file,master_path_no_ext + ".pdf",row,col)
