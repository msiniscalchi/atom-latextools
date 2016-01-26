# THE LATEXTOOLS MANUAL

**Atom Edition**

by Marciano Siniscalchi

## Introduction

LaTeXTools simplifies the preparation of LaTeX documents on the Atom text editor. See the `README` file for highlights. This manual contains installation instructions, as well as a detailed description of the facilities LaTeXTools offers.


## Installation

### All Platforms

If you are reading this document, you have already installed LaTeXTools, so congratulations :) In any event, installation is performed in the usual way, from `Settings|Install` in Atom, or using the `apm` command.

You will need to install two additional Atom packages. The second is, strictly speaking, optional, but you are likely to need it if you soft-wrap your lines.

* `language-latex`: this is required for LaTeX syntax highlighting. It is also necessary for snippets to work correctly, as it defines text scopes for LaTeX text and math.
* `grammar-token-limit`: Atom currently has a known limitation: the syntax highlighter will stop working after 100 tokens in a single line. You  will get no highlighting, or inconsistent highligting. This package allows you to raise that limit. I use 300. Don't go crazy, but experiment.

You should also make sure that the `atom` executable is installed and on your path. TODO ELABORATE

### Windows

On Windows, both `miktex` and `texlive` are supported distributions. You need to specify which distribution you use in Settings: see below.

If you use `texlive`, make sure you also install `latexmk`. (This is included in the full install, but may be omitted if you install a smaller subset of the distribution.)

`SumatraPDF` is the only supported viewer. The reason is that it supports inverse and forward search; other viewers do not.

To ensure that inverse search works, TODO ELABORATE

#### Settings

**NOTE:** only the options listed below are currently implemented. Disregard any other options you see in the Settings page.

* *Win32 Atom Executable*: set this if `atom` is not on your path. Leave blank otherwise
* *Win32 Distro*: one of `miktex`, `texlive`. **Required.**
* *Win32 Sumatra*: path to the SumatraPDF executable. Leave blank if SumatraPDf is on your path.
* *Win32 Texpath*: path to tex and friends. Leave blank if they are on your path.


### OS X

On OS X, use the `MacTeX` distribution. The only currently supported PDF viewer is `Skim`, which supports forward and inverse search.

If you install the "base" distribution (not the full one), you need to install `latexmk` separately using the `tlmgr` package manager.

To set up inverse search on Skim, go to the Preferences menu, select the Sync tab, and choose Atom from the Presets drop-down list.

#### Settings

* *Darwin Texpath*: path to tex and friends. If you are running the latest version of OS X (El Capitan) and the latest version of MacTeX (2015), leave this blank. You can also (most likely) leave this blank if you *are not* running El Capitan, regardless of your MacTeX version. However, if you *are* running El Capitan with a pre-2015 version of MacTeX, you need to enter the path to the `texbin` directory. See Section 8 of [this document](https://tug.org/mactex/UpdatingForElCapitan.pdf) for details.


### Linux

On Linux, `texlive` is the officially supported distribution. For the time being, only the `okular` viewer is supported. It does provide forward and inverse search.

Make sure to install the `latexmk` package; you can use the `tlmgr` utility, or (possibly) your distribution's package manager.

TODO explain how to configure inverse search

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

**Command:** `latextools:build`
**Keybinding:** `ctrl-alt-b` (Linux and Windows), `cmd-option-b` (OS X)

This invokes either `texify` (Windows, MikTeX distribution) or `latexmk` (TeXLive, all platforms, including MacTeX) to build the current TeX file.

**Note**: as specified in the [Installation](#installation) section, this means that you must make sure that `latexmk` is installed if you use TeXlive (or MacTeX, which is basically the OS X version of TeXLive). Otherwise, building will fail.

After compilation, LaTeXTools will show a panel ("LaTeXTools Console") at the bottom of the editor tab and display any errors or warnings. Every such error or warning is clickable: it will move the cursor to the offending line in the tex source, so that you can easily fix the problem.

The LaTeXTools Console stays visible after compilation by default, even if there is no error. (This will become configurable in a later version.) To dismiss it, use `C-l, escape`. Make sure the focus is currently on a tex editor tab, or this keybinding will not work.

Finally, if there were no errors, LaTeXTools will launch your PDF previewer and, by default, jump to the location corresponding to the position of the cursor in the tex source file ("forward search"). Also, by default, the focus will remain on Atom. These behaviors are configurable via settings.

### Multi-file documents

Multi-file documents are fully supported. You need to add a line at the top of each *included* file to point LaTeXTools to the *root* file. This is used both for compilation and for reference / cite completion.

The syntax is as follows: the first line of the file must be

  %! TEX root = rootfile.tex

(Of course, replace `rootfile.tex` with the name of your actual root file.) After you add this line, save your file---otherwise, this directive will not be recognized.

### Customizing the build process

You can select a specific tex engine and/or pass tex options in two ways. One is to use the package settings, documented in [the next section](#build-settings). The other is to use the following lines at the top of your tex source file; in a multi-file document, these must be in the root file.

  %! TEX program = ...
  %! TEX option = ...

The acceptable values for `program` are currently `pdflatex` (the default engine), `xelatex` and `lualatex`. Options are passed to your engine, and hence depend upon your tex distribution.

Please note: passing options can both be a security risk (if e.g. you enable `write18` or similar) and cause unintended breakage or bugs--that is, they may interfere with the normal functioning of the plugin.

### Build settings

* *Darwin Texpath*, *Linux Texpath*, *Win32 Texpath*, and *Win32 Distro*: see the [Introduction](#introduction) above.
* *Keep Focus*: if `true` (default), the focus remains on the Atom editor when the PDF file is opened in the previewer. If `false`, focus goes to the PDF viewer.
* *Forward Sync*: if `true` (default), a forward search is performed, so the PDF viewer displays the location corresponding to the current cursor position. If `false`, no forward search is performed.
* *Builder*: currently, a single option is available, `texify-latexmk`.
* *Builder Settings Program*: one of `pdflatex`, `xelatex`, `lualatex`. Selects the tex engine to use.
* *Builder Settings Options*: an array of command-line options to pass to the tex engine
