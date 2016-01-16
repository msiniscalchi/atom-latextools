# LaTeXTools for Atom

by Marciano Siniscalchi

This is an Atom port of the [LaTeXTools package](http://github.com/SublimeText/LaTeXTools) for Sublime Text (currently maintained by Ian Bacher and myself).

Currently (v0.7.3, 1/15/2016), the following features are implemented:

* Compile and view PDF files, using the `MikTeX` distribution and the `SumatraPDF` previewer on Windows, `MacTeX` and `Skim` on OSX, and `texlive` and `okular` on Linux.
* The TeX program to use (`pdflatex`, `xelatex` or `lualatex`) can be selected either in the settings, or via a `%!TEX program = ` directive. Similarly, options can be passed to the TeX program via settings or via a `%!TEX option = ` directive.
* Forward and inverse search with the above PDF previewers
* Parse the tex log output and list errors and warnings in the "LaTeXTools console." Jump to the line containing an error/warning by clicking on the error/warning message in the LaTeXTools Console.
* Reference completion via a convenient select view (with fuzzy search); autotriggered by default upon typing `\ref{`, or via a keybinding
* Bibliography completion (from one or more `.bib` files), also via a select view; autotriggered by default upon typing `\cite{` and friends, or via a keybinding. The way citations are displayed can be customized.
* Wrap selection in `\emph`, `\textbf` and friends, or in arbitrary commands; wrap lines in arbitrary environment. (Check the keybindings).
* Find the last environment opened with `\begin{env}` and close it with the corresponding `\end{env}`.
* Matching `$` and smart quotes: typing `$` yields `$ $` with the cursor between the dollar signs; typing `'` or `"` yields one or two backquotes and one or two quotes, with the cursor in the middle. Wrapping existing text in dollar signs or quotes is also supported
* Full support for multi-file projects by adding  `%!TEX root = master.tex` at the top of each included file. This includes error/warning reporting, forward / inverse search, and reference / citation completion. (Note: program and option directives must be given in the master file.)
* Virtually all LaTeXTools snippets.

**Keybindings**: by default, these are essentially the same as in Sublime Text, except that the **build** command is bound to `C-alt-b`, where `C` is `ctrl` on Windows and Linux, and `cmd` on OSX. All other commands are triggered via combinations that start with `C-l`. As in Sublime, the "select line" command is remapped to `C-l,C-l`.

Missing functionality to be implemented, roughly in the order I plan to add it:

* Fill helper (autocompletion of various commands, such as  `\include`/`\input`, `\usepackage`, `\includegraphics`, etc.)
* Better documentation :)
* Toggling functions on/off: e.g., temporarily stop jumping to the current line in the PDF file after compilation. (Actually I'm not sure about this; maybe the listener pattern used in Atom can serve as a good replacement.)
* Other functionality in the Sublime Text package


The package does **not** provide syntax highlighting. Rather, it is supposed to be used in conjunction with the `language-latex` package: this *must* be installed for snippets to work.

*Warning*: you will see many package settings. For now, only a few are actually honored. You are better off leaving everything as per defaults, except possibly for the path to your tex distro and PDF previewer (if necessary).

A final note: there are a couple of other nice LaTeX packages for Atom. Each implements a specific function: compiling / viewing,  reference completion, etc. However, the objective of this package is to eventually provide the *entire* functionality of the LaTeXTools plugin for Sublime Text.

Help is welcome!
