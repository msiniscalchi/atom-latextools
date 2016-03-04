{LTool, get_tex_root, is_file} = require './ltutils'
{exec, execFile} = require 'child_process'
path = require 'path'

module.exports =

class Viewer extends LTool

  constructor: (viewerRegistry, ltConsole) ->
    super(ltConsole)
    @viewerRegistry = viewerRegistry

  jumpToPdf: (te) ->
    # if te isn't set, do nothing...
    unless te?
      console.log 'Could not find TextEditor for jump'
      return

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

      pdf_file = master_path_no_ext + '.pdf'
      if not is_file(pdf_file)
        log_file = master_path_no_ext + '.log'
        message =
          "Could not find PDF file #{pdf_file}. If no errors appeared from " +
          "the build, please check your log file, #{log_file}"

        atom.notifications.addError message

        @ltConsole.addContent(
          message,
          file: log_file,
          level: 'error'
        )
        return

      forward_sync = atom.config.get("latextools.forwardSync")
      keep_focus = atom.config.get("latextools.keepFocus")

      viewerName = atom.config.get("latextools.viewer")
      viewerClass = @viewerRegistry.get viewerName

      @ltConsole.addContent("Using viewer #{viewerName}")

      unless viewerClass?
        atom.notifications.addError(
          "Could not find viewer #{viewerName}. Please check your config."
        )
        return if viewerName is 'default'
        viewerClass = @viewerRegistry.get 'default'
        return unless viewerClass?

      viewer = new viewerClass(@ltConsole)

      if forward_sync
        viewer.forwardSync pdf_file, current_file, row, col,
          keepFocus: keep_focus
      else
        viewer.viewFile pdf_file, keepFocus: keep_focus
