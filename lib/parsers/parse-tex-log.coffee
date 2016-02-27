# Parsing code, ported from ST's LaTeXTools (python)

fs = require 'fs'
path = require 'path'
process = require 'process'

## Some utility functions

# debug

DEBUG = false

parseDebugLog = null

debug = (str) ->
  if DEBUG
    if !parseDebugLog
      try
        homedir = process.env.HOME || process.env.USERPROFILE
        logfilename = path.join(homedir, "parseTeXLog.out")
        parseDebugLog = fs.openSync(logfilename, 'w')
      catch e
        console.log("cannot open " + logfilename)
    fs.writeSync(parseDebugLog, str + "\n")

debug_skip_file = (filename) ->
  true # for now


# From http://stackoverflow.com/questions/5515869/string-length-in-bytes-in-javascript
byteLength = (str) ->
  # returns the byte length of an utf8 string
  s = str.length
  i = s - 1
  while i >= 0
    code = str.charCodeAt(i)
    if (code > 0x7f && code <= 0x7ff)
      s++
    else if (code > 0x7ff && code <= 0xffff)
      s+=2
    if (code >= 0xDC00 && code <= 0xDFFF)
      i-- # trail surrogate
    i--
  return s
  # for i=str.length-1; i>=0; i--) {
  #   var code = str.charCodeAt(i);
  #   if (code > 0x7f && code <= 0x7ff) s++;
  #   else if (code > 0x7ff && code <= 0xffff) s+=2;
  #   if (code >= 0xDC00 && code <= 0xDFFF) i--; //trail surrogate
  # }
  # return s;


# Count occurrences of an element in an array

count = (array, target) ->
  ct = 0
  ct++ for el in array when el == target
  ct

# Repeat a string multiple times

repeat = (times, string) ->
  ret = ""
  ret += string for i in [1..times]
  ret


# Is this a file:

isfile = (name) ->
  try
    s = fs.statSync(name)
  catch e
    return false
  return s.isFile()


module.exports.parse_tex_log = (data) ->

  # console.log("Started parse_tex_log")
  #
  # console.log("Testing utility functions")
  # console.log("isfile: ", isfile("c:\test.txt"))
  # console.log("repeat: " + repeat(2, "test"))
  # console.log("count:", count("apple", 'p'))
  # console.log("byteLength:", byteLength("apple"))

  errors = []
  warnings = []
  parsing = []

  # Split data into lines while in binary form
  # Then decode using guessed encoding
  # We need the # of bytes per line, not the # of chars (codepoints), to undo TeX's line breaking
  # so we construct an array of tuples:
  #   (decoded line, length of original byte array)

  # COFFE/JAVASCRIPT CHANGE: here we GET THE ENCODED STRING, but compute bytes as above
  # and hope for the best

  # One important difference: in Python, splitlines() takes care of all line breaks on different plats
  # In javascript, split() also removes the breaking characte, but there may e an \r.
  # So we kill them all and hope for the best.

  data = data.replace(/\r/g, '')
  log = ([l, byteLength(l)] for l in data.split('\n'))
  log_iterator = log[Symbol.iterator]()


  # loop over all log lines; construct error message as needed
  # This will be useful for multi-file documents

  # some regexes
  # Structure (+ means captured, - means not captured)
  # + maybe " (for Windows)
  # + maybe a drive letter and : (for Windows)
  # + maybe . NEW: or ../ or ..\, with repetitions
  # + then any char, matched NON-GREEDILY (avoids issues with multiple files on one line?)
  # + then .
  # + then any char except for whitespace or " or ); at least ONE such char
  # + then maybe " (on Windows/MikTeX)
  # - then whitespace or ), or end of line
  # + then anything else, captured for recycling
  # This should take care of e.g. "(./test.tex [12" or "(./test.tex (other.tex"
  # NOTES:
  # 1. we capture the initial and ending " if there is one; we'll need to remove it later
  # 2. we define the basic filename parsing regex so we can recycle it
  # 3. we allow for any character besides "(" before a file name starts. This gives a lot of
  #   false positives but we kill them with os.path.isfile
  file_basic = /\"?(?:[a-zA-Z]\:)?(?:\.|(?:\.\.\/)|(?:\.\.\\))*.+?\.[^\s\"\)\.]+\"?/
  #file_basic = new RegEx(file_basic_s)
  #file_rx = new RegExp("[^\(]*?\((" + file_basic.source + ")(\s|\"|\)|$)(.*)")
  file_rx = /[^\(]*?\(("?(?:[a-zA-Z]\:)?(?:\.|(?:\.\.\/)|(?:\.\.\\))*.+?\.[^\s"\)\.]+"?)(\s|\"|\)|$)(.*)/
  # Useless file #1: {filename.ext}; capture subsequent text
  # Will avoid nested {'s as these can't really appear, except if file names have braces
  # which is REALLY bad!!!
  file_useless1_rx = /\{\"?(?:\.|\.\.\/)*[^\.]+\.[^\{\}]*\"?\}(.*)/
  # Useless file #2: <filename.ext>; capture subsequent text
  file_useless2_rx = /<\"?(?:\.|\.\.\/)*[^\.]+\.[^>]*\"?>(.*)/
  pagenum_begin_rx = /\s*\[\d*(.*)/
  line_rx = /^l\.(\d+)\s(.*)/    # l.nn <text>
  warning_rx = /^(.*?) Warning: (.+)/ # Warnings, first line
  line_rx_latex_warn = /input line (\d+)\.$/# Warnings, line number
  matched_parens_rx = /\([^()]*\)/# matched parentheses, to be deleted (note: not if nested)
  assignment_rx = /\\[^=]*=/  # assignment, heuristics for line merging
  # Special case: the xy package, which reports end of processing with "loaded)" or "not reloaded)"
  xypic_begin_rx = /[^()]*?(?:not re)?loaded\)(.*)/
  xypic_rx = /.*?(?:not re)?loaded\)(.*)/
  # Special case: the comment package, which prints ")" after some text
  comment_rx = /Excluding comment '.*?'(.*)/

  files = []
  xypic_flag = false # If we have seen xypic, report a warning, not an error for incorrect parsing

  handle_warning = (l) ->

    if files.length is 0
      location = "[no file]"
      parsing.push("PERR [handle_warning no files] " + l)
    else
      location = files[files.length-1]

    # Exec returns an array: first, the matched expression, then the captured groups.
    warn_match_line = line_rx_latex_warn.exec(l)
    if warn_match_line
      warn_line = warn_match_line[1]
      warnings.push([location, warn_line, l])
    else
      warnings.push([location, -1, l])


  # State definitions
  STATE_NORMAL = 0
  STATE_SKIP = 1
  STATE_REPORT_ERROR = 2
  STATE_REPORT_WARNING = 3

  state = STATE_NORMAL

  # Use our own iterator instead of for loop
  # log_iterator = log.__iter__()
  # ATOM: magic!

  line_num=0
  line = ""
  linelen = 0

  recycle_extra = false    # Should we add extra to newly read line?
  reprocess_extra = false    # Should we reprocess extra, without reading a new line?
  emergency_stop = false   # If TeX stopped processing, we can't pop all files
  incomplete_if = false   # Ditto if some \if... statement is not complete

  #console.log("about to start while true loop")

  while true
    # first of all, see if we have a line to recycle (see heuristic for "l.<nn>" lines)
    if recycle_extra
      [line, linelen] = [extra, extralen]
      recycle_extra = false
      line_num +=1
    else if reprocess_extra
      line = extra # NOTE: we must remember that we are reprocessing. See long-line heuristics
    else # we read a new line
      # save previous line for "! File ended while scanning use of..." message
      prev_line = line
      try
        log_next = log_iterator.next() # will fail when no more lines; values won't
        [line, linelen] = log_next.value
        line_num += 1
      catch e
        #console.log("could not read next iterator: line #{line_num}")
        break

    # Now we deal with TeX's decision to truncate all log lines at 79 characters
    # If we find a line of exactly 79 characters, we add the subsequent line to it, and continue
    # until we find a line of less than 79 characters
    # The problem is that there may be a line of EXACTLY 79 chars. We keep our fingers crossed but also
    # use some heuristics to avoid disastrous consequences
    # We are inspired by latexmk (which has no heuristics, though)

    # HEURISTIC: the first line is always long, and we don't care about it
    # also, the **<file name> line may be long, but we skip it, too (to avoid edge cases)
    # We make sure we are NOT reprocessing a line!!!
    # Also, we make sure we do not have a filename match, or it would be clobbered by exending!
    if (!reprocess_extra) && (line_num>1) && (linelen>=79) && (line[0:2] != "**")
      debug ("Line #{line_num} is #{line.length} characters long; last char is #{line[line.length-1]}")
      # HEURISTICS HERE
      extend_line = true
      recycle_extra = false
      # HEURISTIC: check first if we just have a long "(.../file.tex" (or similar) line
      # A bit inefficient as we duplicate some of the code below for filename matching
      file_match = file_rx.exec(line)
      if file_match
        debug("MATCHED (long line)")
        file_name = file_match[1]
        file_extra = file_match[2] + file_match[3] # don't call it "extra"
        # remove quotes if necessary, but first save the count for a later check
        #.log("before count: file_name = " + file_name)
        quotecount = count(file_name,'\"')
        file_name = file_name.replace(/"/g, '')
        # NOTE: on TL201X pdftex sometimes writes "pdfTeX warning" right after file name
        # This may or may not be a stand-alone long line, but in any case if we
        # extend, the file regex will fire regularly
        if file_name.slice(-6)=="pdfTeX" && file_extra.slice(0,8)==" warning"
          debug("pdfTeX appended to file name, extending")
        # Else, if the extra stuff is NOT ")" or "", we have more than a single
        # file name, so again the regular regex will fire
        else if file_extra not in [")", ""]
          debug("additional text after file name, extending")
        # If we have exactly ONE quote, we are on Windows but we are missing the final quote
        # in which case we extend, because we may be missing parentheses otherwise
        else if quotecount==1
          debug("only one quote, extending")
        # Now we have a long line consisting of a potential file name alone
        # Check if it really is a file name
        else if (!isfile(file_name)) and debug_skip_file(file_name)
          debug("Not a file name")
        else
          debug("IT'S A (LONG) FILE NAME WITH NO EXTRA TEXT")
          extend_line = false # so we exit right away and continue with parsing

      while extend_line
        debug("extending: " + line)
        try
          # different handling for Python 2 and 3
          log_next_extra = log_iterator.next()
          [extra, extralen] = log_next_extra.value
          debug("extension? " + extra)
          line_num += 1 # for debugging purposes
          # HEURISTIC: if extra line begins with "Package:" "File:" "Document Class:",
          # or other "well-known markers",
          # we just had a long file name, so do not add
          if extralen>0 && (extra.slice(0,5)=="File:" || extra.slice(0,8)=="Package:" || extra.slice(0,15)=="Document Class:") || (extra.slice(0,9)=="LaTeX2e <") || extra.match(assignment_rx)
            debug("Found File: and friends, or LaTeX2e, or assignment_rx match")
            extend_line = false
            # no need to recycle extra, as it's nothing we are interested in
          # HEURISTIC: when TeX reports an error, it prints some surrounding text
          # and may use the whole line. Then it prints "...", and "l.<nn> <text>" on a new line
          # pdftex warnings also use "..." at the end of a line.
          # If so, do not extend
          else if line.slice(-3)=="..." # and line_rx.match(extra): # a bit inefficient as we match twice
            debug("Found [...]")
            extend_line = false
            recycle_extra = true # make sure we process the "l.<nn>" line!
          else
            line += extra
            debug("Extended: " + line)
            linelen += extralen
            if extralen < 79
              extend_line = false
        catch e
          console.log("something wrong in extend line:")
          console.log(e)
          extend_line = false # end of file, so we must be done. This shouldn't happen, btw
    # We may skip the above "if" because we are reprocessing a line, so reset flag:
    reprocess_extra = false
    # Check various states
    if state==STATE_SKIP
      state = STATE_NORMAL
      continue
    if state==STATE_REPORT_ERROR
      # skip everything except "l.<nn> <text>"
      debug("Reporting error in line: " + line)
      # We check for emergency stops here, too, because it may occur before the l.nn text
      if line.length>0 && line.indexOf("! Emergency stop.") >= 0
        emergency_stop = true
        debug("Emergency stop found")
        continue
      err_match = line_rx.exec(line)
      if not err_match
        continue
      # now we match!
      state = STATE_NORMAL
      err_line = err_match[1]
      err_text = err_match[2]
      # err_msg is set from last time
      if files.length is 0
        location = "[no file]"
        parsing.push("PERR [STATE_REPORT_ERROR no files] " + line)
      else
        location = files[files.length-1]
      debug("Found error: " + err_msg)
      errors.push([location, err_line, err_msg,  err_text])
      continue
    if state==STATE_REPORT_WARNING
      # add current line and check if we are done or not
      current_warning += line
      if line[line.length-1]=='.'
        handle_warning(current_warning)
        current_warning = null
        state = STATE_NORMAL # otherwise the state stays at REPORT_WARNING
      continue
    if line==""
      continue

    # Sometimes an \if... is not completed; in this case some files may remain on the stack
    # I think the same format may apply to different \ifXXX commands, so make it flexible
    if line.length>0 and line.trim().slice(0,23)=="(\\end occurred when \\if" && line.trim().slice(-15)=="was incomplete)"
      incomplete_if = true
      debug(line)

    # Skip things that are clearly not file names, though they may trigger false positives
    if line.length>0 && (line.slice(0,5)=="File:" || line.slice(0,8)=="Package:" || line.slice(0,15)=="Document Class:") || (line.slice(0,9)=="LaTeX2e <")
      continue

    # Are we done? Get rid of extra spaces, just in case (we may have extended a line, etc.)
    if line.trim() == "Here is how much of TeX's memory you used:"
      if files.length>0
        if emergency_stop || incomplete_if
          debug("Done processing, files on stack due to known conditions (all is fine!)")
        else if xypic_flag
          parsing.push("PERR [files on stack (xypic)] " + files.join(';'))
        else
          parsing.push("PERR [files on stack] " + files.join(';'))
        files=[]
      # break
      # We cannot stop here because pdftex may yet have errors to report.

    # Special error reporting for e.g. \footnote{text NO MATCHING PARENS & co
    if line.length>0 && line.indexOf("! File ended while scanning use of") >= 0
      scanned_command = line.slice(35,-2) # skip space and period at end
      # we may be unable to report a file by popping it, so HACK HACK HACK
      log_next = log_iterator.next() # <inserted text>
      log_next = log_iterator.next()
      log_next = log_iterator.next()
      [file_name, linelen] = log_next.value
      file_name = file_name.slice(3) # here is the file name with <*> in front
      errors.push([file_name, -1, "TeX STOPPED: " + line.slice(2,-2)+prev_line.slice(-5), ""])
      continue

    # Here, make sure there was no uncaught error, in which case we do more special processing
    # This will match both tex and pdftex Fatal Error messages
    if line.length>0 && line.indexOf("==> Fatal error occurred,") >= 0
      debug("Fatal error detected")
      if errors.length is 0
        errors.push(["", -1, "TeX STOPPED: fatal errors occurred. Check the TeX log file for details",""])
      continue

    # If tex just stops processing, we will be left with files on stack, so we keep track of it
    if line.length>0 && line.indexOf("! Emergency stop.") >= 0
      state = STATE_SKIP
      emergency_stop = true
      debug("Emergency stop found")
      continue

    # TOo many errors: will also have files on stack. For some reason
    # we have to do differently from above (need to double-check: why not stop processing if
    # emergency stop, too?)
    if line.length>0 && line.indexOf("(That makes 100 errors; please try again.)") >= 0
      errors.push(["", -1, "Too many errors. TeX stopped.", ""])
      debug("100 errors, stopping")
      break

    # catch over/underfull
    # skip everything for now
    # Over/underfull messages end with [] so look for that
    if line.slice(0,8) == "Overfull" || line.slice(0,9) == "Underfull"
      if line.slice(-2)=="[]" # one-line over/underfull message
        continue
      ou_processing = true
      while ou_processing
        try
          log_next = log_iterator.next() # will fail when no more lines
          [line, linelen] = log_next.value
        catch
          debug("Over/underfull: StopIteration (#{line_num})")
          break
        line_num += 1
        debug("Over/underfull: skip " + line + " (#{line_num}) ")
        # Sometimes it's " []" and sometimes it's "[]"...
        if line.length>0 && line.slice(0,3) == " []" || line.slice(0,2) == "[]"
          ou_processing = false
      if ou_processing
        warnings.push(["",-1, "Malformed LOG file: over/underfull"])
        warnings.push(["", -1, "Please let me know via GitHub"])
        break
      else
        continue

    # Special case: the bibgerm package, which has comments starting and ending with
    # **, and then finishes with "**)"
    if line.length>0 && line.slice(0,2) == "**" && line.slice(-3) == "**)" && files && files.slice(-1)[0] && files.slice(-1)[0].indexOf("bibgerm") >= 0 # note [0]
      debug("special case: bibgerm")
      debug(repeat(files.length, " ") + files.slice(-1) + " (#{line_num})")
      files.pop()
      continue

    # Special case: the relsize package, which puts ")" at the end of a
    # line beginning with "Examine \". Ah well!
    if line.length>0 && line.slice(0,9) == "Examine \\" && line.slice(-3) == ". )" && files && files.slice(-1)[0] && files.slice(-1)[0].indexOf("relsize") >= 0
      debug("special case: relsize")
      debug(repeat(files.length, " ") + files.slice(-1)[0] + " (#{line_num})")
      files.pop()
      continue

    # Special case: the comment package, which puts ")" at the end of a
    # line beginning with "Excluding comment 'something'"
    # Since I'm not sure, we match "Excluding comment 'something'" and recycle the rest
    comment_match = comment_rx.exec(line)
    if comment_match && files && files.slice(-1)[0] && files.slice(-1)[0].indexOf("comment") >= 0
      debug("special case: comment")
      extra = comment_match[1]
      debug("Reprocessing " + extra)
      reprocess_extra = true
      continue

    # Special case: the numprint package, which prints a line saying
    # "No configuration file... found.)"
    # if there is no config file (duh!), and that (!!!) signals the end of processing :-(

    if line.length>0 && line.trim() == "No configuration file `numprint.cfg' found.)" && files && files.slice(-1)[0] && files.slice(-1)[0].indexOf("numprint") >= 0
      debug("special case: numprint")
      debug(repeat(files.length, " ") + files.slice(-1)[0] + " (#{line_num})")
      files.pop()
      continue

    # Special case: xypic's "loaded)" at the BEGINNING of a line. Will check later
    # for matches AFTER other text.
    xypic_match = xypic_begin_rx.exec(line)
    if xypic_match
      debug("xypic match before: " + line)
      # Do an extra check to make sure we are not too eager: is the topmost file
      # likely to be an xypic file? Look for xypic in the file name
      if files && files.slice(-1)[0] && files.slice(-1)[0].indexOf("xypic") >= 0
        debug(repeat(files.length, " ") + files.slice(-1)[0] + " (#{line_num})")
        files.pop()
        extra = xypic_match[1]
        debug("Reprocessing " + extra)
        reprocess_extra = true
        continue
      else
        debug("Found loaded) but top file name doesn't have xy")

    # mostly these are caused by hyperref and re-using internal identifiers
    if line.length>0 && line.indexOf("pdfTeX warning (ext4): destination with the same identifier") >= 0
      # add warning
      handle_warning(line) # Original was different but I don't udnerstand it!
      continue

    line = line.trim() # get rid of initial spaces
    # note: in the next line, and also when we check for "!", we use the fact that "and" short-circuits
    if line.length>0 && line[0]==')' # denotes end of processing of current file: pop it from stack
      if files
        debug(repeat(files.length, " ") + files.slice(-1)[0] + " (#{line_num})")
        files.pop()
        extra = line.slice(1)
        debug("Reprocessing " + extra)
        reprocess_extra = true
        continue
      else
        parsing.push("PERR [')' no files]")
        break

    # Opening page indicators: skip and reprocess
    # Note: here we look for matches at the BEGINNING of a line. We check again below
    # for matches elsewhere, but AFTER matching for file names.
    pagenum_begin_match = pagenum_begin_rx.exec(line)
    if pagenum_begin_match
      extra = pagenum_begin_match[1]
      debug("Reprocessing " + extra)
      reprocess_extra = true
      continue

    # Closing page indicators: skip and reprocess
    # Also, sometimes we have a useless file <file.tex, then a warning happens and the
    # last > appears later. Pick up such stray >'s as well.
    if line.length>0 && line[0] in [']', '>']
      extra = line.slice(1)
      debug("Reprocessing " + extra)
      reprocess_extra = true
      continue

    # Useless file matches: {filename.ext} or <filename.ext>. We just throw it out
    file_useless_match = file_useless1_rx.exec(line) || file_useless2_rx.exec(line)
    if file_useless_match
      extra = file_useless_match[1]
      debug("Useless file: " + line)
      debug("Reprocessing " + extra)
      reprocess_extra = true
      continue


    # this seems to happen often: no need to push / pop it
    if line.slice(0,12)=="(pdftex.def)"
      continue

    # Now we should have a candidate file. We still have an issue with lines that
    # look like file names, e.g. "(Font)     blah blah data 2012.10.3" but those will
    # get killed by the isfile call. Not very efficient, but OK in practice
    debug("FILE? Line:" + line)
    file_match = file_rx.exec(line)
    if file_match
      debug("MATCHED")
      file_name = file_match[1]
      debug("with file name: " + file_name)
      extra = file_match[2] + file_match[3]
      debug("and extra: " + extra)
      #.log("file_name:" + file_name)
      # remove quotes if necessary
      file_name = file_name.replace(/"/g, "")
      #.log("file_name afer replace: " + file_name)
      # on TL2011 pdftex sometimes writes "pdfTeX warning" right after file name
      # so fix it
      # TODO: report pdftex warning
      if file_name.slice(-6)=="pdfTeX" && extra.slice(0,8)==" warning"
        debug("pdfTeX appended to file name; removed")
        file_name = file_name.slice(-6)
        extra = "pdfTeX" + extra
      # This kills off stupid matches
      if (!isfile(file_name)) && debug_skip_file(file_name)
        #continue
        # NOTE BIG CHANGE HERE: CONTINUE PROCESSING IF NO MATCH
        # nothing here!
      else
        debug("IT'S A FILE!")
        files.push(file_name)
        debug(repeat(files.length, " ") + files.slice(-1)[0] + " (#{line_num})")
        # Check if it's a xypic file
        if (!xypic_flag) && file_name.length>0 && file_name.indexOf("xypic") >= 0
          xypic_flag = true
          debug("xypic detected, demoting parsing error to warnings")
        # now we recycle the remainder of this line
        debug("Reprocessing " + extra)
        reprocess_extra = true
        continue

    # Special case: match xypic's " loaded)" markers
    # You may think we already checked for this. But, NO! We must check both BEFORE and
    # AFTER looking for file matches. The problem is that we
    # may have the " loaded)" marker either after non-file text, or after a loaded
    # file name. Aaaarghh!!!
    xypic_match = xypic_rx.exec(line)
    if xypic_match
      debug("xypic match after: " + line)
      # Do an extra check to make sure we are not too eager: is the topmost file
      # likely to be an xypic file? Look for xypic in the file name
      if files && files.slice(-1)[0] && files.slice(-1)[0].indexOf("xypic") >= 0
        debug(repeat(files.length, " ") + files.slice(-1)[0] + " (%#{line_num})")
        files.pop()
        extra = xypic_match[1]
        debug("Reprocessing " + extra)
        reprocess_extra = true
        continue
      else
        debug("Found loaded) but top file name doesn't have xy")

    if line.length>0 && line[0]=='!' # Now it's surely an error
      debug("Error found: " + line)
      # If it's a pdftex error, it's on the current line, so report it
      if line.indexOf("pdfTeX error") >= 0
        err_msg = line.slice(1).trim() # remove '!' and possibly spaces
        # This may or may not have a file location associated with it.
        # Be conservative and do not try to report one.
        errors.push(["", -1, err_msg, ""])
        errors.push(["", -1, "Check the TeX log file for more information",""])
        continue
      # Now it's a regular TeX error
      err_msg = line.slice(2) # skip "! "
      # next time around, err_msg will be set and we'll extract all info
      state = STATE_REPORT_ERROR
      continue

    # Second match for opening page numbers. We now use "search" which matches
    # everywhere, not just at the beginning. We do so AFTER matching file names so we
    # don't miss any.
    pagenum_begin_match = pagenum_begin_rx.exec(line) # ATOM: this acctually was SEARCH not MATCH
    if pagenum_begin_match
      debug("Matching [xx after some text")
      extra = pagenum_begin_match[1]
      debug("Reprocessing " + extra)
      reprocess_extra = true
      continue


    warning_match = warning_rx.exec(line)
    if warning_match
      # if last character is a dot, it's a single line
      if line[line.length-1] == '.'
        handle_warning(line)
        continue
      # otherwise, accumulate it
      current_warning = line
      state = STATE_REPORT_WARNING
      continue

  # If there were parsing issues, output them to debug
  if parsing.length>0
    warnings.push(["", -1, "(Log parsing issues. Disregard unless something else is wrong.)"])
    print_debug = true
    for l in parsing
      debug(l)

  if DEBUG && parseDebugLog
    fs.closeSync(parseDebugLog)
    parseDebugLog = null # ATOM: it's a globbal variable, so we need to null it.
  return [errors, warnings]
