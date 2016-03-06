# LaTeXTools for Atom

by Ian Bacher and Marciano Siniscalchi

This is an Atom port of the [LaTeXTools package](http://github.com/SublimeText/LaTeXTools) for Sublime Text. It aims to provide a 'one-stop' solution for all your TeXing needs.

Currently (v0.8.0, 3/6/2016), the following features are implemented:

* Finally (as of v0.7.5), a readable User's Manual, though still *in progress*: see the file `MANUAL.md` (also accessible [here](https://github.com/msiniscalchi/atom-latextools/blob/master/MANUAL.md)). It currently covers installation, compiling and previewing, and reference / citation completion.
* Compile and view PDF files, using the `MikTeX` or `texlive` distributions and the `SumatraPDF` previewer on Windows, `MacTeX` and `Skim` on OSX, and `texlive` and `okular` on Linux. Alternatively, use the [pdf-view](https://atom.io/packages/pdf-view) package.
* Select the TeX engine and pass options to it via `% !TEX` directives, or Atom settings.
* Forward and inverse search with the above PDF previewers
* Parse the tex log output and list errors and warnings in the "LaTeXTools console." Jump to the line containing an error/warning by clicking on the error/warning message in the LaTeXTools Console.
* Reference completion
* Bibliography completion (from one or more `.bib` files). The way citations are displayed can be customized.
* Wrap selection LaTeX commands and environments.
* Find the last environment opened with `\begin{env}` and close it with the corresponding `\end{env}`.
* Matching `$` and smart quotes: typing `$` yields `$ $` with the cursor between the dollar signs; typing `'` or `"` yields one or two backquotes and one or two quotes, with the cursor in the middle. Wrapping existing text in dollar signs or quotes is also supported
* Full support for multi-file projects by adding  `% !TEX root = master.tex` at the top of each included file. This supports error/warning reporting, forward / inverse search, and reference / citation completion.
* Virtually all LaTeXTools snippets.


Missing functionality to be implemented, roughly in the order I plan to add it:

* Toggling functions on/off: e.g., temporarily stop jumping to the current line in the PDF file after compilation. (Actually I'm not sure about this; maybe the listener pattern used in Atom can serve as a good replacement.)
* Fill helper (autocompletion of various commands, such as  `\include`/`\input`, `\usepackage`, `\includegraphics`, etc.)
* Other functionality in the Sublime Text package


The package does **not** provide syntax highlighting. Rather, it is supposed to be used in conjunction with the `language-latex` package: this *must* be installed for snippets to work.

*Warning*: you will see many package settings. The manual (`MANUAL.md`) describes the settings that are actually honored; other settings are place-holders for future functionality.

A final note: there are a couple of other nice LaTeX packages for Atom. Each implements a specific function: compiling / viewing,  reference completion, etc. However, the objective of this package is to provide an integrated solution for TeX editing.

Help is welcome!
