{LTool,get_tex_root} = require './ltutils'
{exec} = require 'child_process'
path = require 'path'
fs = require 'fs'
{parse_tex_log} = require './parsers/parseTeXLog'
parse_tex_directives = require './parsers/tex-directive-parser'

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

    user_program = 'pdf' if user_program is 'pdflatex'

    options =  ["-cd", "-e", "-f", "-#{user_program}",
      "-interaction=nonstopmode", "-synctex=1"]\
        .concat ["-latexoption=\"#{texopt}\"" for texopt in user_options]

    command = ["latexmk"].concat(options, "\"#{texfile}\"").join(' ')
    @ltConsole.addContent(command,br=true)

    return command

  texify: (dir, texfile, texfilename, user_options, user_program) ->
    @ltConsole.addContent("texify builder (internal)",br=true)

    options = ["-b", "-p"]

    user_program = switch user_program
      when 'pdflatex' then 'pdftex'
      when 'xelatex' then 'xetex'
      when 'lualatex' then 'luatex'
      else user_program

    options.push "--engine=#{user_program}"

    tex_options = ["--synctex=1"].concat user_options
    tex_options_string = "--tex-option=\"#{tex_options.join(' ')}\""
    options = options.concat [tex_options_string]

    program = "pdflatex" # unused for now

    command = ["texify"].concat(options, "\"#{texfile}\"").join(' ')
    @ltConsole.addContent(command,br=true)

    return command

  build: ->
    @ltConsole.show()
    @ltConsole.clear()

    te = atom.workspace.getActiveTextEditor()
    if te == ''
      @ltConsole.addContent("Focus the text editor before invoking a build")
      return

    # save on build

    if te.isModified()
      te.save()

    fname = get_tex_root(te)

    parsed_fname = path.parse(fname)

    filedir = parsed_fname.dir
    filebase = parsed_fname.base  # base includes the extension but not the dir
    filename = parsed_fname.name  # name only includes the name (no dir, no ext)

    # TODO also read from shebang line and "project" file
    # TODO get program as well
    directives = parse_tex_directives fname,
      keyMaps: 'ts-program': 'program',
      multiValues: ['options']

    user_options = atom.config.get("latextools.builderSettings.options")
    user_options = user_options.concat directives.options

    # white-list the selectable programs
    # on Windows / miktex, allow both pdftex, etc and pdflatex
    whitelist = ["pdflatex", "xelatex", "lualatex"]
    if process.platform == 'win32'
      whitelist = whitelist.concat ["pdftex", "xetex", "luatex"]
    if directives.program in whitelist
      user_program = directives.program
    else
      user_program = atom.config.get("latextools.builderSettings.program")

    # Now prepare path
    # TODO: also env if needed
    # Note: texpath must NOT include $PATH!!!

    # Apparently the key is different on Win and non-Win
    if process.platform == "win32"
      current_path = process.env.Path
    else
      current_path = process.env.PATH
    texpath = atom.config.get("latextools." + process.platform + ".texpath")
    @ltConsole.addContent("Platform: #{process.platform}; texpath: #{texpath}")
    cmd_env = process.env
    if texpath
      cmd_env.PATH = current_path + path.delimiter + texpath
      @ltConsole.addContent("setting PATH = #{process.env.PATH}")

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

      cmd_env.MYTEST = "Hello, world!"
      command = command

      # cd to dir and run command; add output to console for now
      exec command, {cwd: filedir, env: cmd_env}, (err, stdout, stderr) =>
        # If there were errors, print them and return
        # if err
        #   @ltConsole.addContent("BUILD ERROR!", br=true)
        #   @ltConsole.addContent(line, br=true) for line in stdout.split('\n')
        #   @ltConsole.addContent(line, br=true) for line in stderr.split('\n')
        # return
        # Parse error log
        fulllogfile = path.join(filedir, filename + ".log") # takes care of quotes
        @ltConsole.addContent("Parsing " + fulllogfile, br=true)
        log = fs.readFileSync(fulllogfile, 'utf8')

        # We need to cd to the root file directory for the
        # file-matching logic to work with texlive (miktex reports full paths)
        # NOTE: we could also do this earlier and avoid setting cwd in the
        # exec call
        process.chdir(filedir)
        [errors, warnings] = parse_tex_log(log)

        @ltConsole.addContent("ERRORS:", br=true)
        for err in errors
          do (err) =>
            if err[1] == -1
              err_string = "#{err[0]}: #{err[2]} [#{err[3]}]"
              @ltConsole.addContent(err_string, br=true)
            else
              err_string = "#{err[0]}:#{err[1]}: #{err[2]} [#{err[3]}]"
#              @ltConsole.addContent err_string, br=true
              @ltConsole.addContent err_string, true, false, =>
                atom.workspace.open(err[0], {initialLine: err[1]-1})
                #te.setCursorBufferPosition([err[1]-1,0])

        @ltConsole.addContent("WARNINGS:", br=true)
        for warn in warnings
          do (warn) =>
            if warn[1] == -1
              warn_string = "#{warn[0]}: #{warn[2]}"
              @ltConsole.addContent(warn_string, br=true)
            else
              warn_string = "#{warn[0]}:#{warn[1]}: #{warn[2]}"
#              @ltConsole.addContent warn_string, br=true
              @ltConsole.addContent warn_string, true, false, =>
                atom.workspace.open(warn[0], {initialLine: warn[1]-1})
                #te.setCursorBufferPosition([warn[1]-1,0])

        # Jump to PDF
        @ltConsole.addContent("Jumping to PDF...", br=true)
        @viewer.jumpToPdf()
