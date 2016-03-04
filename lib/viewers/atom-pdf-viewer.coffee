BaseViewer = require './base-viewer'

module.exports =
class AtomPdfViewer extends BaseViewer
  _forwardSync = (view, texFile, line) ->
    view?.forwardSync?(texFile, line)

  _getActivePaneItem = (pdfFile) ->
    for item of atom.workspace.getPaneItems()
      if item.filePath is pdfFile
        return item

  _open = (pdfFile, callback = null) ->
    atom.workspace.open(pdfFile, split: 'right').done callback

  forwardSync: (pdfFile, texFile, line, col, opts = {}) ->
    view = _getActivePaneItem pdfFile
    return _forwardSync view, texFile, line if view?

    @ltConsole.addContent "Opening #{pdfFile}"
    _open pdfFile, (view) -> _forwardSync(view, texFile, line)

  viewFile: (pdfFile, opts = {}) ->
    @ltConsole.addContent "Opening #{pdfFile}"
    _open pdfFile
