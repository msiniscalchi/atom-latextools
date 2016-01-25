# The LaTeXTools Manual
** Atom Edition **

by Marciano Siniscalchi

Introduction
============
LaTeXTools simplifies the preparation of LaTeX documents on the Atom text editor. See the `README` file for highlights. This manual contains installation instructions, as well as a detailed description of the facilities LaTeXTools offers.

Installation
============

All Platforms
-------------
If you are reading this document, you have alredy installed LaTeXTools, so congratulations :) In any event, installation is performed in the usual way, from `Settings|Install` in Atom, or using the `apm` command.

You will need to install two additional Atom packages. The second is, strictly speaking, optional, but you are likely to need it if you soft-wrap your lines.

* `language-latex`: this is required for LaTeX syntax highlighting. It is also necessary for snippets to work correctly, as it defines text scopes for LaTeX text and math.
* `grammar-token-limit`: Atom currently has a known limitation: the syntax highlighter will stop working after 100 tokens in a single line. You  will get no highlighting, or inconsistent highligting. This package allows you to raise that limit. I use 300. Don't go crazy, but experiment.

You should also make sure that the `atom` executable is installed and on your path. TODO ELABORATE

Windows
-------
On windows, both `miktex` and `texlive` are supported distributions. You need to specify which distribution you use in Settings: see below.

`SumatraPDF` is the only supported viewer. The reason is that it supports inverse and forward search; other viewers do not.

To ensure that inverse search works, TODO FIX HERE!

** Settings **

** NOTE: ** only the options listed below are currently implemented. Disregard any other options you see in the Settings page.

* *Win32 Atom Executable*: set this if `atom` is not on your path. Leave blank otherwise
* *Win32 Distro*: one of `miktex`, `texlive`. ** Required. **
* *Win32 Sumatra*: path to the SumatraPDF executable. Leave blank if SumatraPDf is on your path.
* *Win32 Texpath*: path to tex and friends. Leave blank if they are on your path.
