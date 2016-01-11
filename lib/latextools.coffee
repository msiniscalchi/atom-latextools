LTConsole = require './ltconsole'
Builder = require './builder'
Viewer = require './viewer'
CompletionManager = require './completion-manager'
SnippetManager = require './snippet-manager'
{Disposable, CompositeDisposable} = require 'atom'
path = require 'path'

module.exports = Latextools =
  ltConsole: null
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
    fillAutoTrigger:
      type: 'boolean'
      default: true
      order: 4
    keepFocus:
      type: 'boolean'
      default: true
      order: 5
    forwardSync:
      type: 'boolean'
      default: true
      order: 6

    commandCompletion:
      type: 'string'
      default: 'prefixed'
      enum: ['always', 'prefixed', 'never']
      order: 7

    hideBuildPanel:
      type: 'string'
      default: 'never'
      enum: ['always', 'no_errors', 'no_warnings', 'never']
      order: 8

    texFileExtensions:
      type: 'array'
      default: ['.tex']
      items:
        type: 'string'
      order: 9

    latextoolsSetSyntax:
      type: 'boolean'
      default: true
    order: 10

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
        keepFocusDelay:
          type: 'number'
          default: 0.5
      order:14
    linux:
      type: 'object'
      properties:
        texpath:
          type: 'string'
          default: "$PATH:/usr/texbin"
        python2:
          type: 'string'
          default: ""
        atomExecutable:
          type: 'string'
          default: ""
        syncWait:
          type: 'number'
          default: 1.5
        keepFocusDelay:
          type: 'numer'
          default: 0.5
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
        command:
          description: "The exact command to run. <strong>Leave this blank</strong> unless you know what you are doing!"
          type: 'array'
          default: []
          items:
            type: 'string'
        displayLog:
          type: 'boolean'
          default: false
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


  activate: (state) ->
    @ltConsole = new LTConsole(state.ltConsoleState)

    # Create viewer first, so by the time we run the builer, it is available
    @viewer = new Viewer(@ltConsole)
    @builder = new Builder(@ltConsole)
    @builder.viewer = @viewer
    @completionManager = new CompletionManager(@ltConsole)
    @snippetManager = new SnippetManager(@ltConsole)



    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view; DEBUG ONLY
    @subscriptions.add atom.commands.add 'atom-workspace', 'latextools:toggle-log': =>
      @ltConsole.toggle_log()
    @subscriptions.add atom.commands.add 'atom-workspace', 'latextools:add-log': =>
      @ltConsole.add_log()
    @subscriptions.add atom.commands.add 'atom-workspace', 'latextools:clear-log': =>
      @ltConsole.clear()

    # Actual commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'latextools:hide-ltconsole': =>
      @ltConsole.hide()
    @subscriptions.add atom.commands.add 'atom-workspace', 'latextools:show-ltconsole': =>
      @ltConsole.show()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:build': =>
      @builder.build()
    @subscriptions.add atom.commands.add 'atom-workspace', 'latextools:jump-to-pdf': =>
      @viewer.jumpToPdf()
    @subscriptions.add atom.commands.add 'atom-workspace', 'latextools:ref-cite-complete': =>
      @completionManager.refCiteComplete()

    # Snippet insertion: added in consumeSnippets

    # Autotriggered functionality
    # add autocomplete to every text editor that has a tex file
    atom.workspace.observeTextEditors (te) =>
      if !( path.extname(te.getPath()) in atom.config.get('latextools.texFileExtensions') )
        return
      @subscriptions.add te.onDidStopChanging =>
        @completionManager.refCiteComplete() if atom.config.get("latextools.refAutoTrigger")
        # add more here?

  deactivate: ->
    @subscriptions.dispose()
    @ltConsole.destroy()

  serialize: ->
    ltConsoleState: @ltConsole.serialize()

  consumeSnippets: (snippets) ->
    @snippetManager.setService(snippets) # potential race?
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:wrap-in-command': => @snippetManager.wrapInCommand()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:wrap-in-environment': => @snippetManager.wrapInEnvironment()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:wrap-in-emph': => @snippetManager.wrapIn("emph")
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:wrap-in-bold': => @snippetManager.wrapIn("bold")
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:wrap-in-underline': => @snippetManager.wrapIn("underline")
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:wrap-in-monospace': => @snippetManager.wrapIn("texttt")
    @subscriptions.add atom.commands.add 'atom-text-editor', 'latextools:close-environment': => @snippetManager.closeEnvironment()
    new Disposable -> @snippets = null
