## 0.1.0 - First Release
* Compiling / previewing on Windows
* Error log parsing
* LaTeXTools snippets

## 0.2.0 - OSX support
* Compiling / previewing on OSX

## 0.3.0
* Jump to errors / warnings

## 0.4.0
* Reference completion

## 0.5.0
* Citation completion from bibliography files

## 0.6.0
* Setting `program` and `option`s using `%!TEX` lines (master file)

## 0.7.0
* Wrap selection in emph, bold, and friends
* Wrap selection in arbitrary command or environment
* Close last opened environment

## 0.7.1
* $ and quotes matching and wrapping
* Fixed issue with multiple options / latexmk

## 0.7.2
* Patched annoying behavior with single-quote matching

## 0.7.3
* Linux support

## 0.7.4
* Enable texlive on Windows
* Fine-tuned quote insertion code
* Small speed-up in cite completion
* Honor ref/cite autocompletion toggles

## 0.7.5
* User manual (*in progress*): building and ref/cite completion
* Catch errors reading log file
* Better handling of Sumatra error code 1; use `-reuse-instance` switch
* Display a SaveAs dialog if build is run with an unsaved text editor
* Fix issues in config object
* Fix error occurring when LaTeXTools is loaded without an active text editor
* Make wrap-in-XXX work as in Sublime Text, using e.g. `C-l C-e` for `emphasize` (rather than `C-l e`, which will be used to insert environments in a later release)
* Fix wrap-in-bold command
* Other bugfixes

## 0.7.6
* Manual fixes

## 0.7.7
* Ian Bacher is now on board as a contributor!
* Snazzy new resizable, colorized LaTeXTools Console, courtesy of Ian
* Lazy-loading modules to improve start-up time
* Settings: display only options that are actually honored
* Insert LaTeX commands or environments
* Allow absolute paths for bibliographies
* Some ref/cite and other fixes
* Updated manual

## 0.8.0
* Support for `pdf-view`!
* Modularized viewer code to facilitate future support for other viewers
* Selectable console text
* Fixed an issue with the log parser
* Increased the size of the exec buffer to avoid errors with large projects
* Report error when no PDF is created
* Various internal improvements and fixes
