BaseViewer = require './base-viewer'
{execFile} = require 'child_process'

module.exports =
class OkularViewer extends BaseViewer
  _getArgs = (opts = {}) ->
    args = ["--unique"]
    args.push "--noraise" if opts?.keepFocus
    args

  okularIsRunning: ->
    new Promise (resolve, reject) ->
      execFile 'ps', ['xw'], (err, stdout, stderr) ->
        unless err?
          for line in stdout.match /^.*([\n\r]+|$)/gm
            if line.indexOf("okular") > 0 and line.indexOf("--unique") > 0
              resolve()
              break

        reject()

  ensureOkular: ->
    @okularIsRunning().catch ->
      new Promise (resolve, reject) ->
        execFile 'okular', ['--unique'], (err, stdout, stderr) ->
          resolve()

  forwardSync: (pdfFile, texFile, line, col, opts = {}) ->
    @ensureOkular().then =>
      @doAfterPause =>
        args = _getArgs opts
        args.push "#{pdfFile}#src:#{line}#{texFile}"
        args.unshift 'okular'
        @runViewer args

  viewFile: (pdfFile, opts = {}) ->
    @ensureOkular().then =>
      @doAfterPause =>
        args = _getArgs opts
        args.push "#{pdfFile}"
        args.unshift 'okular'
        @runViewer args
