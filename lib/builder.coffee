{LTool,get_tex_root} = require './ltutils'
{exec} = require 'child_process'
path = require 'path'
fs = require 'fs'
{parse_tex_log} = require './parseTeXLog'

module.exports =

class Builder extends LTool

  # The next two methods simply return the command line to execute
  # The actual processing is done in the build method
  #
  # dir: directory of master file
  # texfile: the base name (name+ext, no directory) of the master file
  # texfilename: name only (no ext no dir) of the master file
  # user_options: any user-specified options for the tex compiler
  # user_program: user-specified tex compiler
  #
  # These methods construct a command line that includes both required
  # options (e.g, to enable synctex, or to get PDF output) and user-specified
  # ones. It also selects the appropriate tex compiler.

  latexmk: (dir, texfile, texfilename, user_options, user_program) ->
    @ltConsole.addContent("latexmk builder",br=true)

    quotes = '\"'

    options = ["-cd", "-e", "-f", "-pdf", "-interaction=nonstopmode"]

    tex_options = ["-synctex=1"].concat(user_options)
    tex_options_cmdline = ["-latexoption=\"" + texopt + "\"" for texopt in tex_options]
    options = options.concat([tex_options_cmdline])

    program = "pdflatex" # unused for now

    command = ["latexmk"].concat(options).concat([quotes + texfile + quotes]).join(' ')
    @ltConsole.addContent(command,br=true)

    return command

  texify: (dir, texfile, texfilename, user_options, user_program) ->
    @ltConsole.addContent("texify builder (internal)",br=true)

    quotes = '\"'

    options = ["-b", "-p"]

    tex_options = ["--synctex=1"].concat(user_options)
    tex_options_string = "--tex-option=\"" + tex_options.join(' ') + "\""
    options = options.concat([tex_options_string])

    program = "pdflatex" # unused for now

    command = ["texify"].concat(options).concat([quotes + texfile + quotes]).join(' ')
    @ltConsole.addContent(command,br=true)

    return command


  build: ->
    @ltConsole.show()

    te = atom.workspace.getActiveTextEditor()
    if te == ''
      @ltConsole.addContent("Focus the text editor before invoking a build")
      return

    # save on build

    if te.isModified()
      te.save()

    fname = get_tex_root(te.getPath())

    parsed_fname = path.parse(fname)

    filedir = parsed_fname.dir
    filebase = parsed_fname.base  # base includes the extension but not the dir
    filename = parsed_fname.name  # name only includes the name (no dir, no ext)

    # TODO also read from shebang line and "project" file
    # TODO get program as well
    user_options = atom.config.get("latextools.builderSettings.options")
    user_program = "" # unused for now

    @ltConsole.addContent("Processing file #{filebase} (#{filename}) in directory #{filedir}",br=true)

    builder = atom.config.get("latextools.builder")
    builder = "texify-latexmk" if builder not in ["texify-latexmk"]

    # Built-in processing via texify or latexmk
    if builder=="texify-latexmk"

      # first, get command to execute, with options
      if process.platform in ["darwin", "linux"]
        command = @latexmk(filedir, filebase, filename, user_options, user_program)
      else
        command = @texify(filedir, filebase, filename, user_options, user_program)

      # cd to dir and run command; add output to console for now
      exec command, {cwd: filedir}, (err, stdout, stderr) =>
        # Parse error log
        @ltConsole.addContent("Parsing ", br=true)
        fulllogfile = path.join(filedir, filename + ".log") # takes care of quotes
        log = fs.readFileSync(fulllogfile, 'utf8')
        [errors, warnings] = parse_tex_log(log)

        @ltConsole.addContent("ERRORS:", br=true)
        @ltConsole.addContent(err, br=true) for err in errors
        @ltConsole.addContent("WARNINGS:", br=true)
        @ltConsole.addContent(warn, br=true) for warn in warnings

        # Jump to PDF unless user told us not to
        if !atom.config.get("latextools.keepFocus")
          @ltConsole.addContent("Jumping to PDF...", br=true)
          @viewer.jumpToPdf()
