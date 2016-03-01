{exec} = require 'child_process'

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
    if Array.isArray command
      command = command.join ' '

    @ltConsole.addContent "Executing #{command}"
    exec command, callback

  handleExec: (err, stdout, stderr) =>
    if err
      @ltConsole.addContent("ERROR #{err.code}")
      @ltConsole.addContent(line) for line in stderr.split('\n')

  canKeepFocus: ->
    true
