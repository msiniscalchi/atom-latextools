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
      try
        command = execSync(
          'osascript -e "POSIX path of (path to app id \\"net.sourceforge.skim-app.skim\\")"'
        ).toString().replace /^\s+|\s+$/g, ''
      catch error
        atom.notifications.addError(
          'Cannot find <a href="http://skim-app.sourceforge.net/">Skim.app</a>' +
          ' on your system. Please ensure that Skim is installed before' +
          ' attempting to run the viewer.'
          dismissable: true
        )
        return

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
