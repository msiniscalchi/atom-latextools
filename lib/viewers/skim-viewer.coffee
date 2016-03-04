BaseViewer = require './base-viewer'
{is_dir} = require '../ltutils'
{execSync} = require 'child_process'
path = require 'path'

module.exports =
class SkimViewer extends BaseViewer
  _getArgs = (opts = {}) ->
    args = ["-r"]
    args.push "-g" if opts?.keepFocus
    args

  forwardSync: (pdfFile, texFile, line, col, opts = {}) ->
    args = _getArgs opts

    command = '/Applications/Skim.app'
    if not is_dir(command)
      command = execSync(
        'osascript -e "POSIX path of (path to app id \"net.sourceforge.skim-app.skim\")"'
      ).replace /^\s+|\s+$/g

    command = path.join command, 'Contents/SharedSupport/displayline'

    args.unshift command
    args.push line, "#{pdfFile}", "#{texFile}"

    @runViewer args

  viewFile: (pdfFile, opts = {}) ->
    args = _getArgs opts

    command = path.join(
      atom.packages.resolvePackagePath("latextools"),
      "lib/displayfile"
    )

    args.unshift command
    args.push "\"#{pdfFile}\""

    @runViewer args
