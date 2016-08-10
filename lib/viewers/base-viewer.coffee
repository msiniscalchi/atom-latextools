{execFile} = require 'child_process'
{quote} = require '../ltutils'

module.exports =
class BaseViewer
  constructor: (ltConsole) ->
    @ltConsole = ltConsole

  forwardSync: (pdfFile, texFile, line, col, opts = {}) ->
    throw
      name: "Not Implemented Error"
      message: "forwardSync() is not implemented"

  viewFile: (pdfFile, opts = {}) ->
    throw
      name: "Not Implemented Error"
      message: "viewFile() is not implemented"

  runViewer: (command, callback = @handleExec) ->
    @ltConsole.addContent "Executing #{quote(command)}"
    if command.length > 1
      execFile command[0], command[1..], callback
    else
      execFile command[0], [], callback

  doAfterPause: (func) ->
    setTimeout func,
      atom.config.get("latextools.#{process.platform}.syncWait") * 1000 or
      1000

  handleExec: (err, stdout, stderr) =>
    if err
      @ltConsole.addContent("ERROR #{err.code}")
      @ltConsole.addContent(line) for line in stderr.split('\n')

  canKeepFocus: ->
    true
