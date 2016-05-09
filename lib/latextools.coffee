LTConsole = null
Builder = null
Viewer = null
ViewerRegistry = null
CompletionManager = null
SnippetManager = null
deleteTempFiles = null
{Disposable, CompositeDisposable} = require 'atom'
path = require 'path'

module.exports = Latextools =
  ltConsole: null
  builder: null
  subscriptions: null
  snippets: null

  config:
    citeAutoTrigger:
      type: 'boolean'
      default: true
      order: 1
    refAutoTrigger:
      type: 'boolean'
      default: true
      order: 2
    refAddParenthesis:
      type: 'boolean'
      default: false
      order: 3
    # fillAutoTrigger:
    #   type: 'boolean'
    #   default: true
    #   order: 4
    keepFocus:
      type: 'boolean'
      default: true
      order: 5
    forwardSync:
      type: 'boolean'
      default: true
      order: 6
    viewer:
      type: 'string'
      default: 'default'
      enum: ['default', 'pdf-view']
      order: 6.5

    # commandCompletion:
    #   type: 'string'
    #   default: 'prefixed'
    #   enum: ['always', 'prefixed', 'never']
    #   order: 7

    # hideBuildPanel:
    #   type: 'string'
    #   default: 'never'
    #   enum: ['always', 'no_errors', 'no_warnings', 'never']
    #   order: 8

    texFileExtensions:
      type: 'array'
      default: ['.tex']
      items:
        type: 'string'
      order: 9

    # latextoolsSetSyntax:
    #   type: 'boolean'
    #   default: true
    #   order: 10

    temporaryFileExtensions:
      type: 'array'
      default: [
        ".blg",".bbl",".aux",".log",".brf",".nlo",".out",".dvi",".ps",
        ".lof",".toc",".fls",".fdb_latexmk",".pdfsync",".synctex.gz",
        ".ind",".ilg",".idx"
      ]
      items:
        type: 'string'
      order: 11
    temporaryFilesIgnoredFolders:
      type: 'array'
      default: [".git", ".svn", ".hg"]
      items:
        type: 'string'
      order: 12

    darwin:
      type: 'object'
      properties:
        texpath:
          type: 'string'
          default: "/Library/TeX/texbin:/usr/texbin:/usr/local/bin:/opt/local/bin"
      order: 13

    win32:
      type: 'object'
      properties:
        texpath:
          type: 'string'
          default: ""
        distro:
          type: 'string'
          default: "miktex"
          enum: ["miktex", "texlive"]
        sumatra:
          type: 'string'
          default: "SumatraPDF.exe"
        atomExecutable:
          type: 'string'
          default: ""
        # keepFocusDelay:
        #   type: 'number'
        #   default: 0.5
      order:14

    linux:
      type: 'object'
      properties:
        texpath:
          type: 'string'
          default: "$PATH:/usr/texbin"
        # python2:
        #   type: 'string'
        #   default: ""
        atomExecutable:
          type: 'string'
          default: ""
        # syncWait:
        #   type: 'number'
        #   default: 1.5
        # keepFocusDelay:
        #   type: 'number'
        #   default: 0.5
      order: 15

    builder:
      type: 'string'
      default: "texify-latexmk"
      order: 16
    builderPath:
      type: 'string'
      default: ""
      order: 17
    builderSettings:
      type: 'object'
      properties:
        program:
          type: 'string'
          default: "pdflatex"
          enum: ["pdflatex", "xelatex", "lualatex"]
        options:
          type: 'array'
          default: []
          items:
            type: 'string'
        # command:
        #   description: "The exact command to run. <strong>Leave this blank</strong> unless you know what you are doing!"
        #   type: 'array'
        #   default: []
        #   items:
        #     type: 'string'
      order: 18


# Still need image opening defaults
# Also, rethink below

    citePanelFormat:
      type: 'array'
      default: ["{author_short} {year} - {title_short} ({keyword})","{title}"]
      order: 19
    citeAutocompleteFormat:
      type: 'string'
      default: "{keyword}: {title}"
      order: 20


  activate: (@state) ->
    @ltConsole = null
    @viewer = null
    @builder = null
    @completionManager = null
    @snippetManager = null
    @viewerRegistry = null

    # function to register a viewer with latextools
    @addViewer = (names, cls) =>
      @requireIfNeeded ['viewer']
      @viewerRegistry.add names, cls

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view; DEBUG ONLY
    @subscriptions.add atom.commands.add 'atom-workspace', 'latextools:toggle-log': =>
      @ltConsole.toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'latextools:add-log': =>
      @ltConsole.addLog()
    @subscriptions.add atom.commands.add 'atom-workspace', 'latextools:clear-log': =>
      @ltConsole.clear()

    # Actual commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'latextools:hide-ltconsole': =>
      @ltConsole.hide()
    @subscriptions.add atom.commands.add 'atom-workspace', 'latextools:show-ltconsole': =>
      @ltConsole.show()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:build': =>
      @requireIfNeeded ['viewer', 'builder']
      # drop to JS to call this.getModel() which is the TextEditor the command
      # is run on
      te = `this.getModel()`
      @builder.build(te)
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:jump-to-pdf': =>
      @requireIfNeeded ['viewer']
      # drop to JS to call this.getModel() which is the TextEditor the command
      # is run on
      te = `this.getModel()`
      @viewer.jumpToPdf(te)
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:ref-cite-complete': =>
      @requireIfNeeded ['completion-manager', 'snippet-manager']
      # drop to JS to call this.getModel() which is the TextEditor the command
      # is run on
      te = `this.getModel()`
      @completionManager.refCiteComplete(te, keybinding=true)
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:ref-cite-keypress': (e) =>
      e.abortKeyBinding()
      @requireIfNeeded ['completion-manager', 'snippet-manager']
      # drop to JS to call this.getModel() which is the TextEditor the command
      # is run on
      te = `this.getModel()`
      setTimeout (=>
        @completionManager.refCiteComplete(te)
      ), 50
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:delete-temp-files': =>
      deleteTempFiles ?= require './commands/delete-temp-files'
      # drop to JS to call this.getModel() which is the TextEditor the command
      # is run on
      te = `this.getModel()`
      deleteTempFiles(te)

    # Snippet insertion

    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:wrap-in-command': =>
      @requireIfNeeded ['snippet-manager']
      @snippetManager.wrapInCommand()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:wrap-in-environment': =>
      @requireIfNeeded ['snippet-manager']
      @snippetManager.wrapInEnvironment()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:insert-command': =>
      @requireIfNeeded ['snippet-manager']
      @snippetManager.insertCmdEnv("command")
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:insert-environment': =>
      @requireIfNeeded ['snippet-manager']
      @snippetManager.insertCmdEnv("environment")
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:wrap-in-emph': =>
      @requireIfNeeded ['snippet-manager']
      @snippetManager.wrapIn("emph")
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:wrap-in-bold': =>
      @requireIfNeeded ['snippet-manager']
      @snippetManager.wrapIn("textbf")
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:wrap-in-underline': =>
      @requireIfNeeded ['snippet-manager']
      @snippetManager.wrapIn("underline")
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:wrap-in-monospace': =>
      @requireIfNeeded ['snippet-manager']
      @snippetManager.wrapIn("texttt")
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:close-environment': =>
      @requireIfNeeded ['snippet-manager']
      @snippetManager.closeEnvironment()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:dollar-sign': =>
      @requireIfNeeded ['snippet-manager']
      @snippetManager.dollarSign()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:backquote': =>
      @requireIfNeeded ['snippet-manager']
      @snippetManager.quotes('`', '\'', '`')
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:quote': =>
      @requireIfNeeded ['snippet-manager']
      @snippetManager.quotes('`', '\'', '\'')
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:double-quote': =>
      @requireIfNeeded ['snippet-manager']
      @snippetManager.quotes('``', '\'\'', '"')

  deactivate: ->
    @subscriptions.dispose()
    @ltConsole.destroy()

  serialize: ->
    ltConsoleState: @ltConsole.serialize()

  consumeSnippets: (snippets) ->
    @requireIfNeeded ['snippet-manager']
    @snippetManager.setService(snippets)
    new Disposable -> @snippets = null

  # Private: ensure modules are loaded on demand
  requireIfNeeded: (modules) ->
    # ltConsole is needed by all, so load it
    unless LTConsole?
      LTConsole = require './ltconsole'
      @ltConsole = new LTConsole @state.ltConsoleState

    for m in modules
      console.log("requiring if needed: #{m}")
      switch m
        when "viewer"
          unless Viewer?
            ViewerRegistry = require './viewer-registry'
            @viewerRegistry = new ViewerRegistry

            @viewerRegistry.add 'pdf-view',
              require './viewers/atom-pdf-viewer'

            switch process.platform
              when 'darwin'
                @viewerRegistry.add ['default', 'skim'],
                  require './viewers/skim-viewer'
              when 'win32'
                @viewerRegistry.add ['default', 'sumatra'],
                  require './viewers/sumatra-viewer'
              else
                @viewerRegistry.add ['default', 'okular'],
                  require './viewers/okular-viewer'

            Viewer = require './viewer'
            @viewer = new Viewer @viewerRegistry, @ltConsole
        when "builder"
          unless Builder?
            Builder = require './builder'
            @builder = new Builder(@ltConsole)
            @builder.viewer = @viewer # NOTE: MUST be loaded first!
        when "completion-manager"
          CompletionManager ?= require('./completion-manager').CompletionManager
          @completionManager ?= new CompletionManager(@ltConsole)
        when "snippet-manager"
          SnippetManager ?= require './snippet-manager'
          @snippetManager ?= new SnippetManager(@ltConsole)
