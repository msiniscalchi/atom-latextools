{LTool,get_tex_root} = require './ltutils'
{exec, execFile} = require 'child_process'
path = require 'path'

module.exports =

class Viewer extends LTool


  _jumpWindows: (texfile, pdffile, row, col, forward_sync, keep_focus) ->
    sumatra_cmd = atom.config.get("latextools.win32.sumatra")
    sumatra_args = ["-reuse-instance"]

    if forward_sync
      sumatra_args = sumatra_args.concat(["-forward-search", '\"'+texfile+'\"', "#{row}"])

    sumatra_args.push('\"'+pdffile+'\"')

    command = sumatra_cmd + ' ' + sumatra_args.join(' ')
    @ltConsole.addContent("Executing " + command, br = true)

    exec command, {}, (err, stdout, stderr) =>
      if err > 1 # weirdness
        @ltConsole.addContent("ERROR #{err.code}: ", br=true)
        @ltConsole.addContent(line, br=true) for line in stderr.split('\n')




  _jumpDarwin: (texfile, pdffile, row, col, forward_sync, keep_focus) ->

    if keep_focus
      skim_args = "-r -g"
    else
      skim_args = "-r"

    if forward_sync
      skim_cmd = '/Applications/Skim.app/Contents/SharedSupport/displayline'
      command = skim_cmd + " #{skim_args} #{row} \"#{pdffile}\" \"#{texfile}\""
    else
      displayfile_cmd = path.join(atom.packages.resolvePackagePath("latextools"), "lib/support/displayfile")
      command = "sh " + displayfile_cmd + " #{skim_args} #{pdffile}"

    @ltConsole.addContent("Executing " + command, br=true)

    exec command, {}, (err, stdout, stderr) =>
      if err  # weirdness
        @ltConsole.addContent("ERROR #{err.code}: ", br=true)
        @ltConsole.addContent(line, br=true) for line in stderr.split('\n')



  _jumpLinux: (texfile, pdffile, row, col, forward_sync, keep_focus) ->

    console.log("in _jumpLinux")

    if keep_focus
      okular_args = "--unique --noraise"
    else
      okular_args = "--unique"

    okular_cmd = 'okular'

    if forward_sync
      command = okular_cmd + " #{okular_args} \"#{pdffile}\#src:#{row} #{texfile}\""
    else
      command = okular_cmd + " #{okular_args} #{pdffile}"

    @ltConsole.addContent("Executing " + command, br=true)

    console.log(command)

    exec command, {}, (err, stdout, stderr) =>
      if err  # weirdness
        @ltConsole.addContent("ERROR #{err.code}: ", br=true)
        @ltConsole.addContent(line, br=true) for line in stderr.split('\n')



  _jumpToPdf: (texfile, pdffile, row, col=1) ->

    # TODO make modular, but for now...

    forward_sync = atom.config.get("latextools.forwardSync")
    keep_focus = atom.config.get("latextools.keepFocus")

    switch process.platform
      when "darwin" then @_jumpDarwin(texfile, pdffile, row, col, forward_sync, keep_focus)
      when "win32" then @_jumpWindows(texfile, pdffile, row, col, forward_sync, keep_focus)
      when "linux" then @_jumpLinux(texfile, pdffile, row, col, forward_sync, keep_focus)
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
    master_file = get_tex_root(te)

    parsed_master = path.parse(master_file)
    parsed_current = path.parse(current_file)

    tex_exts = atom.config.get("latextools.texFileExtensions")
    if parsed_master.ext in tex_exts && parsed_current.ext in tex_exts
      master_path_no_ext = path.join(parsed_master.dir, parsed_master.name)
      @ltConsole.addContent("Jump to #{row},#{col}")
      @_jumpToPdf(current_file,master_path_no_ext + ".pdf",row,col)
