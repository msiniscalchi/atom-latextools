{get_tex_root} = require '../ltutils'
{Directory} = require 'atom'
fs = require 'fs'
path = require 'path'

module.exports = (te) ->
  unless te?
    atom.notifications.addWarning(
      "Cannot delete temp files as no active text editor was found"
    )
    return

  rootFile = get_tex_root(te)
  directory = new Directory(path.dirname(rootFile))

  tempFileExts = atom.config.get('latextools.temporaryFileExtensions')
  ignoredFolders = atom.config.get('latextools.temporaryFilesIgnoredFolders')

  fileHandler = (file) ->
    new Promise (resolve, reject) ->
      filePath = file.getPath()
      for ext in tempFileExts
        if filePath.endsWith(ext)
          file.exists().then(
            fs.unlink filePath, (error) ->
              if error?
                reject error
              else
                resolve filePath
          )
          return

      resolve filePath

  folderHandler = (directory) ->
    promises = []
    directory.getEntries (error, entries) ->
      for entry in entries
        if entry instanceof Directory
          if entry.getBaseName() not in ignoredFolders
            promises.push folderHandler(entry)
        else
          promises.push fileHandler(entry)

    Promise.all promises

  folderHandler(directory).then(
    atom.notifications.addSuccess("Deleted temporary files"),
  ).catch (error) ->
    atom.notifications.addError(
      "An error occurred while trying to delete temporary files",
      detail: error
    )
