# THE LATEXTOOLS MANUAL

**Atom Edition** v0.8.0 (3/6/2016)

by Ian Bacher and Marciano Siniscalchi

## Introduction

LaTeXTools simplifies the preparation of LaTeX documents on the Atom text editor. See the `README` file for highlights. This manual contains installation instructions, as well as a detailed description of the facilities LaTeXTools offers.


## Installation

### All Platforms

If you are reading this document, you have already installed LaTeXTools, so congratulations :) In any event, installation is performed in the usual way, from `Settings|Install` in Atom, or using the `apm` command.

You will need to install one additional Atom package, and possibly one or two more. The second is, strictly speaking, optional, but you are likely to need it if you soft-wrap your lines. The third is entirely optional--only install it if you are not happy with native PDF viewers on your platform.

* `language-latex`: this is required for LaTeX syntax highlighting. It is also necessary for snippets to work correctly, as it defines text scopes for LaTeX text and math.
* `grammar-token-limit`: Atom currently has a known limitation: the syntax highlighter will stop working after 100 tokens in a single line. You  will get no highlighting, or inconsistent highligting. This package allows you to raise that limit. I use 300. Don't go crazy, but experiment.
* `pdf-view`: a Javascript-based PDF viewer that integrates nicely with Atom. It now supports both forward and inverse search.

You should also make sure that the `atom` executable is installed and on your path. TODO ELABORATE

### Windows

On Windows, both `miktex` and `texlive` are supported distributions. You need to specify which distribution you use in Settings: see below.

If you use `texlive`, make sure you also install `latexmk`. (This is included in the full install, but may be omitted if you install a smaller subset of the distribution.)

`SumatraPDF` is the only supported viewer (in addition to the Atom-based `pdf-view`). The reason is that it supports inverse and forward search; other viewers do not.

To ensure that inverse search works, TODO ELABORATE

#### Settings


| Setting | CSON | Description |
|------|----------|-------------|
| *Win32 Atom Executable* | `win32.atomoExecutable` | Path to `atom` command, if not on your path. Leave blank otherwise|
| *Win32 Distro* | `win32.distro` | one of `miktex`, `texlive`|
| *Win32 Sumatra* | `win32.sumatra` | Path to the SumatraPDF executable. Leave blank if SumatraPDf is on your path.|
| *Win32 Texpath* | `win32.texpath` | Path to tex and friends. Leave blank if they are on your path.|


### OS X

On OS X, use the `MacTeX` distribution. The only currently supported PDF viewer (in addition to the Atom-based `pdf-view`) is `Skim`, which supports forward and inverse search.

If you install the "base" distribution (not the full one), you need to install `latexmk` separately using the `tlmgr` package manager.

To set up inverse search on Skim, go to the Preferences menu, select the Sync tab, and choose Atom from the Presets drop-down list.

#### Settings

* *Darwin Texpath*: path to tex and friends. If you are running the latest version of OS X (El Capitan) and the latest version of MacTeX (2015), leave this blank. You can also (most likely) leave this blank if you *are not* running El Capitan, regardless of your MacTeX version. However, if you *are* running El Capitan with a pre-2015 version of MacTeX, you need to enter the path to the `texbin` directory. See Section 8 of [this document](https://tug.org/mactex/UpdatingForElCapitan.pdf) for details.


### Linux

On Linux, `texlive` is the officially supported distribution. For the time being, only the `okular` viewer is supported (in addition to the Atom-based `pdf-view`). It does provide forward and inverse search.

Make sure to install the `latexmk` package; you can use the `tlmgr` utility, or (possibly) your distribution's package manager.

To set up inverse search on Okular, go to "Settings", then "Configure Okular..." and then "Editor". In the "Editor" dropdown menu, choose "Custom Text Editor" and type "atom %f:%l" in the "Command" field. If you are on the Atom Beta channel, change atom to atom-beta.

#### Settings

* *Linux Texpath*: path to tex and friends. If you have a default install of `texlive`, leave this blank. Otherwise, point this to the `texbin` directory.


## LaTeXTools Commands and Keybindings

LaTeXTools provides a variety of commands and facilities, roughly divided into the following categories:

* Building and previewing PDF documents
* Inserting references and citations
* Inserting or completing environments; wrapping existing text in commands or environments
* Inserting snippets in text and math mode

Most keybindings use the following convention:

* on OS X, they consist of `cmd-l` followed by one or more additional keystrokes
* on Linux and Windows, they consist of `ctrl-l` followed by one or more additional keystrokes
* There is one exception: to compile a TeX file, LaTeXTools uses `ctrl-alt-b` (Linux and Windows) or `cmd-option-b` (Mac). This seems to be in line with Atom conventions for `build` commands.

In the following, I will use the notation `C-l` to refer to either `cmd-l` or `ctrl-l`, depending on the platform.

By default, Atom uses `C-l` to select the current line. That is rebound to `C-l C-l` with LaTeXTools (i.e., hit `C-l` twice). This seems like a decent compromise: only one keybinding is modified, and even that is redefined to something only slightly more complex. Of course, you are free to use personalized keybindings, as everywhere else in Atom.


## Compiling and Previewing documents

### Build command: general functionality

| Keybinding | Command |
|---|----|
| `ctrl-alt-b` (Linux and Windows), `cmd-option-b` (OS X) | `latextools:build`  |

This invokes either `texify` (Windows, MikTeX distribution) or `latexmk` (TeXLive, all platforms, including MacTeX) to build the current TeX file.

**Note**: as specified in the [Installation](#installation) section, this means that you must make sure that `latexmk` is installed if you use TeXlive (or MacTeX, which is basically the OS X version of TeXLive). Otherwise, building will fail.

After compilation, LaTeXTools will show a panel ("LaTeXTools Console") at the bottom of the editor tab and display any errors or warnings. Every such error or warning is clickable: it will move the cursor to the offending line in the tex source, so that you can easily fix the problem.

The LaTeXTools Console stays visible after compilation by default, even if there is no error. (This will become configurable in a later version.) To dismiss it, use `C-l  escape`, or click the close box. Make sure the focus is currently on a tex editor tab, or this keybinding will not work. Also note that the console is resizable, using the mouse as usual.

Finally, if there were no errors, LaTeXTools will launch your PDF previewer and, by default, jump to the location corresponding to the position of the cursor in the tex source file ("forward search"). Also, by default, the focus will remain on Atom. These behaviors are configurable via settings.

The text in the LaTeXTools console is selectable as usual.

### Jump to current location in the PDF file

| Keybinding | Command |
|---|----|
| `C-l j` | `latextools:jump-to-pdf`|

Jumps to the location in the PDF file corresponding to the current cursor position. Multi-file documents are fully supported: see the [next section](#multi-file-documents).

### Multi-file documents

Multi-file documents are fully supported. You need to add a line at the top of each *included* file to point LaTeXTools to the *root* file. This is used both for compilation and for reference / cite completion.

The syntax is as follows: the first line of the file must be
```
% !TEX root = rootfile.tex
```
(Of course, replace `rootfile.tex` with the name of your actual root file.) After you add this line, save your file---otherwise, this directive will not be recognized.

### Customizing the build process

You can select a specific tex engine and/or pass tex options in two ways. One is to use the package settings, documented in [the next section](#build-settings). The other is to use the following lines at the top of your tex source file; in a multi-file document, these must be in the root file.
```
% !TEX program = ...
% !TEX option = ...
```
The acceptable values for `program` are currently `pdflatex` (the default engine), `xelatex` and `lualatex`. Options are passed to your engine, and hence depend upon your tex distribution.

Please note: passing options can both be a security risk (if e.g. you enable `write18` or similar) and cause unintended breakage or bugs--that is, they may interfere with the normal functioning of the plugin.

### Build settings

| Setting | CSON | Description |
|---|---|---|
| *Darwin Texpath* <br> *Linux Texpath* <br> *Win32 Texpath* <br> *Win32 Distro* | | See the [Installation](#installation) section above.|
| *Keep Focus* | `keepFocus` | If `true` (default), the focus remains on the Atom editor when the PDF file is opened in the previewer. If `false`, focus goes to the PDF viewer.|
|*Forward Sync* | `forwardSync` | If `true` (default), a forward search is performed, so the PDF viewer displays the location corresponding to the current cursor position. If `false`, no forward search is performed.|
| *Builder* | `builder` | Currently, a single option is available, `texify-latexmk`.|
| *Builder Settings Program* | `builderSettings.program`| One of `pdflatex`, `xelatex`, `lualatex`. Selects the tex engine to use.|
| *Builder Settings Options* | `builderSettings.options` | Array of command-line options to pass to the tex engine.|

### Viewer settings

Note: these are *in addition* to any platform settings that may be relevant to you (e.g., settings for `SumatraPDF`), and the above focus- and sync-related bulild settings.

| Setting | CSON | Description |
|---|---|---|
| *Viewer* | `viewer` | `default` (native, platform-specific viewer) or `pdf-view` (Atom-based).|


### Notes on pdf-view

The Atom `pdf-view` package is supported as of v. 0.8.0. A couple of comments are in order.

First, `pdf-view` uses the `synctex` command-line utility to implement backward and forward search. This means that you must have the `synctex` binary somewhere on your path; alternatively, `pdf-view` has a setting that allows you to specify where it is.

The issue is how to make sure you have the `synctex` binary. If you are on Mac OS X and you installed the full MacTeX distro, you do---there is nothing else you need to do. If, however, you didn't install it, then you need to figure out how to add it using the MacTeX `tlmgr` utility. The same applies to TeXLive on Linux (and Windows): either you installed the entire distribution, or you must add the relevant package.

On Windows, MikTeX does *not* provide `synctex` at all. On my machine, I installed the minimal TeXLive scheme, then added the `synctex` package (search for `synctex` in the TeXLive package manager). Then, I pointed `pdf-view` to the right location (the TeXLive binary directory). Just to be clear: the TeXLive distro is *not needed*; it was just the easiest, laziest way for me to get `synctex`. I could not find a stand-alone binary. If anyone has a better idea of how to get this to work, let me know!

Second: by default, LaTeXTools opens the PDF preview in a separate pane, side-by-side with the pane containing the TeX source. (Remember, a pane is a collection of tabs in Atom). This works well if you have a large screen, or good eyesight. If neither of these apply to you (I have a 13in laptop and horrible eyesight!) you can simply drag the PDF tab to the pane containing the tab with your TeX source. Forward and inverse search will continue to work, but you now have the full width of your Atom window available for the TeX and PDF views (of course, you will need to switch between the two tabs).

Note that the *Keep Focus* and *Forward Sync* settings are honored. If you keep the TeX and PDF files side by side, you probably want to leave *Keep Focus* on (the default). Otherwise, you probably want to set *Keep Focus* to false, so upon compilation the PDF tab is displayed.

Finally, forward search in `pdf-viw` is not perfect. Basically, `pdf-view` gets the page right, but does not scroll the document up/down so the relevant line (the one corresponding to the cursor position in the TeX file) is visible. This is a `pdf-view` limitation.


## Reference and Citation Completion

| Keybinding | Command |
|---|----|
| `C-l x` or auto-triggered | `latextools:ref-cite-complete` |

The basic idea is to help you insert labels in `\ref{}` commands and bibtex keys in `\cite{}` commands. The appropriate key combination shows a list of available labels or keys, and you can easily select the appropriate one. Full filtering facilities are provided.

In order to find all applicable labels and bibtex keys, the plugin looks at the **saved** file. So, if you invoke this command and do not see the label or key you just entered, perhaps you haven't saved the file.

Only bibliographies in external `.bib` files are supported: no `\bibitem...`. Sorry.

Multi-file documents are fully supported.

### Details

By default, as soon as you type, for example, `\ref{` or `\cite`, a select view panel is shown. This is a drop-down list displayed at the top of the screen, similar to the  Command Palette.

The panel lists, respectively, all the labels in your tex file(s), or all the entries in the bibliographies you reference your file(s) using the `\bibliography{}` command. This is the default *auto-trigger* behavior, and it can be a big time saver. You can, however, turn it off by way of preference settings: see below.

Once the select view panel is shown, you can narrow down the entries shown by typing a few characters. What you type will be fuzzy-matched against the label names or, for citations, the content of the first displayed line in each entry (by default, the author names, year of publication, short title and citation key: see below). This is *very* convenient, and one of the best Atom features: try it!

If auto-triggering is off, when you type e.g. `\ref{`, Atom helpfully provides the closing brace, leaving your cursor between the two braces. Now, you need to type `C-l x` to get the select view panel  showing all labels in the current file.

In either case, you then select the label you want, hit Return, and LaTeXTools inserts the **full ref command**, as in `\ref{my-label}`. The LaTeX command `\eqref` works the same way.  Citations from bibtex files are also supported in a similar way. Use `\cite{}`,  `\citet{}`,  `\citeyear{}` etc.

### Multiple citations

One often needs to enter multiple citations, as e.g. in `\cite{paper1,paper2}`. This is easy to do: either cite the first paper, e.g. `\cite{paper1}` and then, *with your cursor immediately before the right brace*, type a comma (`,`). Again, the default auto-trigger behavior is that the quick panel with appear, and you can select the second paper. If auto-trigger is off, then you enter the comma, then use the shortcut `C-l x` to bring up the quick panel (note: you *must* add the comma before invoking the shortcut, or you won't get the intended result). Of course, you can enter as many citations as you want.

### Citation customization

The display of bibliographic entries is *customizable*. There is a setting, *Cite Panel Format*, that controls exactly what to display in each of the two lines each entry gets in the citation panel. Options include author, title, short title, year, bibtex key, and journal. This is useful because people may prefer to use different strategies to refer to papers---author-year, short title-year, bibtex key (!), etc. Since only the first line in each quick panel entry is searchable, how you present the information matters. The default should be useful for most people.

### Multi-file support

Multi-file documents are fully supported. If you have a `% !TEX root = ...` directive at the top of the current file, LaTeXTools looks for references, as well as `\bibliography{}` commands, in the root file and in all recursively included files. You can also use a project file to specify the root file (to be documented).

### Miscellaneous

LaTeXTools now also looks `\addbibresource{}` commands, which provides basic compatibility with biblatex.

### Completion Settings

| Setting | CSON | Description |
|---|---|---|
|*Cite Auto Trigger* | `citeAutoTrigger` | Automatically show the select view panel upon typing `\cite{` and friends (default: `true`)|
|*Ref Auto Trigger* | `refAutoTrigger` | Automatically show the select view panel upon typing `\ref{` and friends (default: `true`)|
| *Ref Add Parenthesis* | `refAddParenthesis` | Automatically add ')' if the reference was preceded by '(' (default: `false`)|
|*Cite Panel Format* | `citePanelFormat` | Format of the primary and secondary line of the citation completion panel. See below.|

To format the citation panel, provide an array of two strings---one for the primary line and one for the secondary line. The format can be arbitrary, and can contain the following placeholder variables:
```
{keyword}
{title}
{title_short}
{author}
{author_short}
{year}
{journal}
```

## LaTeX commands and environments

LaTeXTools provide facilities to quickly enter commands and environments, as well as wrapping selected text in them.

### Inserting commands and environments


| Keybinding | Command |
|---|----|
|`C-l c`| `latextools:insert-command`|
|`C-l e` or `C-l n`| `latextools:insert-environment`|

To insert a LaTeX command such as `\color{}` or similar, type the command without backslash (i.e. `color`), then hit `C-l c`. This will replace e.g. `color` with `\color{}` and place the cursor between the braces. Type the argument of the command, then hit Tab to exit the braces.

Similarly, typing `C-l e` gives you an environment: e.g. `test` becomes
```
	\begin{test}

	\end{test}
```
and the cursor is placed inside the environment thus created. Again, Tab exits the environment.

Note that all these commands are undoable: thus, if e.g. you accidentally hit `C-l c` but you really meant `C-l e`, a quick `C-z`, followed by `C-l e`, will fix things.


### Wrapping existing text in commands and environments

The following table assumes that the text `blah` is currently *selected*.

| Keybinding | Result |
|---|----|
| `C-l C-c` | `blah` is replaced with `\cmd{blah}`; `cmd` is selected |
| `C-l C-e` | `blah` is replaced with `\emph{blah}`|
| `C-l C-b` | `blah` is replaced with `\textbf{blah}`|
| `C-l C-u` | `blah` is replaced with `\underline{blah}`|
| `C-l C-m` | `blah` is replaced with `\texttt{blah}`|
| `C-l C-n` | `blah` is replaced with `\begin{env}`, `blah`, `\end{env}` on three separate lines; `env` is selected in the first and third lines.|

The functionality just described is mostly useful if you are creating a command or environment from scratch. However, you sometimes have existing text, and just want to apply some formatting to it via a LaTeX command or environment, such as `\emph` or `\begin{theorem}...\end{theorem}`.

LaTeXTools' wrapping facility helps you in just these circumstances. All commands below are activated via a key binding, and *require some text to be selected first*. Also, as a mnemonic aid, *all wrapping commands involve typing `C-l C-something`* (which you can achieve by just holding the `C-` key down after typing `l`).

`C-l C-e`, `C-l C-b`, `C-l C-u` and `C-l C-m` should be self-explanatory. `C-l C-c` wraps the selected text in a LaTeX command structure. If the currently selected text is `blah`, you get `\cmd{blah}`, and the letters `cmd` are highlighted. Replace them with whatever you want, then hit Tab: the cursor will move to the end of the command. Finally, `C-l C-n` wraps the selected text in a LaTeX environment structure. You get `\begin{env}`,`blah`, `\end{env}` on three separate lines, with `env` selected. Change `env` to whatever environment you want, then hit Tab to move to the end of the environment.

These commands also work if there is no selection. In this case, they try to do the right thing; for example, `C-l C-e` gives `\emph{}` with the cursor between the curly braces.
