BaseViewer = require './base-viewer'

module.exports =
class SumatraViewer extends BaseViewer
  _getArgs = (opts = {}) ->
    args = ["--unique"]
    args.push "--noraise" if opts?.keepFocus
    args

  forwardSync: (pdfFile, texFile, line, col, opts = {}) ->
    args = _getArgs opts
    args.push "#{pdfFile}#src:#{line}#{texFile}"
    args.unshift 'okular'
    @runViewer args

  viewFile: (pdfFile, opts = {}) ->
    args = _getArgs opts
    args.push "#{pdfFile}"
    args.unshift 'okular'
    @runViewer args
