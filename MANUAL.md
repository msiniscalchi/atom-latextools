# THE LATEXTOOLS MANUAL

**Atom Edition**

by Marciano Siniscalchi

## Introduction

LaTeXTools simplifies the preparation of LaTeX documents on the Atom text editor. See the `README` file for highlights. This manual contains installation instructions, as well as a detailed description of the facilities LaTeXTools offers.


## Installation
============

### All Platforms

If you are reading this document, you have already installed LaTeXTools, so congratulations :) In any event, installation is performed in the usual way, from `Settings|Install` in Atom, or using the `apm` command.

You will need to install two additional Atom packages. The second is, strictly speaking, optional, but you are likely to need it if you soft-wrap your lines.

* `language-latex`: this is required for LaTeX syntax highlighting. It is also necessary for snippets to work correctly, as it defines text scopes for LaTeX text and math.
* `grammar-token-limit`: Atom currently has a known limitation: the syntax highlighter will stop working after 100 tokens in a single line. You  will get no highlighting, or inconsistent highligting. This package allows you to raise that limit. I use 300. Don't go crazy, but experiment.

You should also make sure that the `atom` executable is installed and on your path. TODO ELABORATE

### Windows

On Windows, both `miktex` and `texlive` are supported distributions. You need to specify which distribution you use in Settings: see below.

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

To set up inverse search on Skim, go to the Preferences menu, select the Sync tab, and choose Atom from the Presets drop-down list.

#### Settings

* *Darwin Texpath*: path to tex and friends. If you are running the latest version of OS X (El Capitan) and the latest version of MacTeX (2015), leave this blank. You can also (most likely) leave this blank if you *are not* running El Capitan, regardless of your MacTeX version. However, if you *are* running El Capitan with a pre-2015 version of MacTeX, you need to enter the path to the `texbin` directory. See Section 8 of [this document](https://tug.org/mactex/UpdatingForElCapitan.pdf) for details.


### Linux

On Linux, `texlive` is the officially supported distribution. For the time being, only the `okular` viewer is supported. It does provide forward and inverse search.

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

* on OS X, they consist of `Cmd-l` followed by one or more additional keystrokes
* on Linux and Windows, they consist of `Ctrl-l` followed by one or more additional keystrokes

In the following, I will use the notation `C-l` to refer to either `Cmd-l` or `Ctrl-l`, depending on the platform.

By default, Atom uses `C-l` to select the current line. That is rebound to `C-l C-l` with LaTeXTools (i.e., hit `C-l` twice). This seems like a decent compromise: only one keybinding is modified, and even that is redefined to something only slightly more complex. Of course, you are free to use personalized keybindings, as everywhere else in Atom.


## Compiling and Previewing documents
