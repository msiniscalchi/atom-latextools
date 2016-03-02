BaseViewer = require './base-viewer'

module.exports =
class SumatraViewer extends BaseViewer
  _getArgs = ->
    [atom.config.get("latextools.win32.sumatra"), "-reuse-instance"]

  forwardSync: (pdfFile, texFile, line, col, opts = {}) ->
    args = _getArgs()
    args.push "-forward-search", "#{texFile}", "#{line}", "#{pdfFile}"
    @runViewer args

  viewFile: (pdfFile, opts = {}) ->
    args = _getArgs()
    args.push "#{pdfFile}"
    @runViewer args

  handleExec: (err, stdout, stderr) =>
    # when it is already running, Sumatra returns error code 1 but no error
    # message, while "the jump" works just fine
    if err && !(err.code == 1 && !stderr)
      @ltConsole.addContent("ERROR #{err.code}")
      @ltConsole.addContent(line, br=true) for line in stderr.split('\n')
