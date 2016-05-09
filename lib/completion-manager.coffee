{LTool,get_tex_root,find_in_files,is_file} = require './ltutils'
LTSimpleSelectList = require './views/ltsimple-select-list-view'
LTTwoLineSelectList = require './views/lttwo-line-select-list-view'
#get_ref_completions = require './get-ref-completions'
get_bib_completions = require './parsers/get-bib-completions'
path = require 'path'
fs = require 'fs'

# ref_rx = /\\(?:eq|page|v|V|auto|name|c|C|cpage)?ref\{/
module.exports.ref_rx_rev = ref_rx_rev =
  /^\{fer(?:qe|egap|v|V|otua|eman|c|C|egapc)?\\/

# Avoids trigger-happy autocomplete
# Multipart regex break-down:
# 1. \(hyphen|foreign)(text|block)quote* - csquotes
# 2. \hybridblockquote* - csquotes
# 3. \(hyphen|foreign)(text|block)cquote* - csquotes
# 4. \hybridcquote* - csquotes
# 5. \(text|block)cquote* - csquotes
# 6. \volcite* - biblatex
# 7. \volcites* - biblatex
# 8. \cites* - biblatex
# 9. most \cite commands
# 10. \cite<> etc. - apacite
module.exports.cite_rx_rev = cite_rx_rev = ///^
(?:
(?:(?:,[^\[\],]*)*\[\}[^\{]*\{
  \*?etouq(?:kcolb|txet)(?:ngierof|nehpyh))|
(?:(?:,[^\[\],]*)*\[\}[^\{]*\{
  \*?etouq(?:kcolbdirbyh))|
(?:(?:,[^\[\],]*)*\[\*?etouq(?:kcolb|txet))|
(?:(?:,[^{},]*)*\{(?:\][^\[]*\[){0,2}\}[^\{]*\{
  \*?etouqc(?:kcolb|txet)(?:ngierof|nehpyh))|
(?:(?:,[^{},]*)*\{(?:\][^\[]*\[){0,2}\}[^\{]*\{
  \*?etouqc(?:kcolbdirbyh))|
(?:(?:,[^{},]*)*\{(?:\][^\[]*\[){0,2}
  \*?etouqc(?:kcolb|txet))|
(?:(?:,[^{},]*)*\{(?:\][^\[]*\[)?\}[^\{}]*\{(?:\][^\[]*\[)?
  eticlo[v|V](?:p|P|f|ft|s|S|t|T|a|A)?)|
(?:(?:,[^{},]*)*\{(?:\][^\[]*\[)?\}[^\{}]*\{(?:\][^\[]*\[)?
  (?:\}[^\{}]*\{(?:\][^\[]*\[)?\}[^\{}]*\{(?:\][^\[]*\[)?)*
  (?:\)[^(]*\(){0,2}
  seticlo[v|V](?:p|P|f|ft|s|S|t|T|a|A)?)|
(?:(?:,[^{},]*)*\{(?:\][^\[]*\[){0,2}
  (?:\}[^\}]*\{(?:\][^\[]*\[){0,2})*
  (?:[\.\*\?]){0,2}(?:\)[^(]*\(){0,2}(?!elyts)(?:[a-zX\*]*?)
  seti(?:C|c(?!lov)[a-z]*[A-Z]?))|
(?:(?:,[^{},]*)*\{(?:\][^\[]*\[){0,2}
  (?:[\.\*\?]){0,2}(?!\*?teser|elyts)(?:[a-zX\*]*?)
  eti(?:C|c(?!lov|m\\)[a-z]*[A-Z]?))|
(?:(?:,[^{},]*)*\{(?:\][^\[]*\[)?
  (?:>[^<]*<)?(?:(?:PN)?raey|rohtua|PN|A)?etic(?:lluf|trohs)?(?:ksam)?)
)\\
///

# differs from the above in having capture groups to capture any
# input
module.exports.cite_rx_rev_key_press = cite_rx_rev_key_press = ///^
(?:
(?:([^\[\],]*)(?:,[^\[\],]*)*\[\}[^\{]*\{
  \*?etouq(?:kcolb|txet)(?:ngierof|nehpyh))|
(?:([^\[\],]*)(?:,[^\[\],]*)*\[\}[^\{]*\{
  \*?etouq(?:kcolbdirbyh))|
(?:([^\[\],]*)(?:,[^\[\],]*)*\[\*?etouq(?:kcolb|txet))|
(?:([^{},]*)(?:,[^{},]*)*\{(?:\][^\[]*\[){0,2}\}[^\{]*\{
  \*?etouqc(?:kcolb|txet)(?:ngierof|nehpyh))|
(?:([^{},]*)(?:,[^{},]*)*\{(?:\][^\[]*\[){0,2}\}[^\{]*\{
  \*?etouqc(?:kcolbdirbyh))|
(?:([^{},]*)(?:,[^{},]*)*\{(?:\][^\[]*\[){0,2}
  \*?etouqc(?:kcolb|txet))|
(?:([^{},]*)(?:,[^{},]*)*\{(?:\][^\[]*\[)?\}[^\{}]*\{(?:\][^\[]*\[)?
  eticlo[v|V](?:p|P|f|ft|s|S|t|T|a|A)?)|
(?:([^{},]*)(?:,[^{},]*)*\{(?:\][^\[]*\[)?\}[^\{}]*\{(?:\][^\[]*\[)?
  (?:\}[^\{}]*\{(?:\][^\[]*\[)?\}[^\{}]*\{(?:\][^\[]*\[)?)*
  (?:\)[^(]*\(){0,2}
  seticlo[v|V](?:p|P|f|ft|s|S|t|T|a|A)?)|
(?:([^{},]*)(?:,[^{},]*)*\{(?:\][^\[]*\[){0,2}
  (?:\}[^\}]*\{(?:\][^\[]*\[){0,2})*
  (?:[\.\*\?]){0,2}(?:\)[^(]*\(){0,2}(?!elyts)(?:[a-zX\*]*?)
  seti(?:C|c(?!lov)[a-z]*[A-Z]?))|
(?:([^{},]*)(?:,[^{},]*)*\{(?:\][^\[]*\[){0,2}
  (?:[\.\*\?]){0,2}(?!\*?teser|elyts)(?:[a-zX\*]*?)
  eti(?:C|c(?!lov|m\\)[a-z]*[A-Z]?))|
(?:([^{},]*)(?:,[^{},]*)*\{(?:\][^\[]*\[)?
  (?:>[^<]*<)?(?:(?:PN)?raey|rohtua|PN|A)?etic(?:lluf|trohs)?(?:ksam)?)
)\\
///

module.exports.CompletionManager =

class CompletionManager extends LTool
  sel_view: null
  sel2_view: null
  sel_panel: null

  constructor: (@ltconsole) ->
    super
    @sel_view = new LTSimpleSelectList
    @sel2_view = new LTTwoLineSelectList


  refCiteComplete: (te, keybinding = false) ->
    max_length = 100 # max length of ref/cite command, including backslash

    cite_rx_rev =
      if keybinding
        cite_rx_rev_key_press
      else
        cite_rx_rev

    current_point = te.getCursorBufferPosition()
    initial_point = [current_point.row, Math.max(0, current_point.column - max_length)]
    range = [initial_point, current_point]
    line = te.getTextInBufferRange(range)

    # This is JPS's awesome trick: reverse the line and match backward regexes!
    # JS/CS don't have string reverse, so instead go to array and reverse that

    line = line.split("").reverse().join("")

    # TODO: pass initial match to select list

    if (keybinding or atom.config.get("latextools.refAutoTrigger")) and
        m = ref_rx_rev.exec(line)
      console.log("found match")
      @refComplete(te)
      return true
    else if (keybinding or atom.config.get("latextools.citeAutoTrigger")) and
        m = cite_rx_rev.exec(line)
      console.log("found match")
      console.log(m)
      @citeComplete(te)
      return true
    else
      return false


    # got_ref = false
    # te.backwardsScanInBufferRange ref_rx, range, ({match, stop}) =>
    #   console.log("found match")
    #   @refComplete(te)
    #   stop()
    #   got_ref = true
    #
    # return if got_ref
    #
    # got_cite = false
    # te.backwardsScanInBufferRange cite_rx, range, ({match, stop}) =>
    #   console.log("found match")
    #   console.log(match)
    #   @citeComplete(te)
    #   stop()
    #   got_cite = true
    #
    # return if got_cite



  refComplete: (te) ->

    fname = get_tex_root(te) # pass TextEditor, thanks to ig0777's patch

    parsed_fname = path.parse(fname)

    filedir = parsed_fname.dir
    filebase = parsed_fname.base  # name only includes the name (no dir, no ext)

    labels = find_in_files(filedir, filebase, /\\label\{([^\}]+)\}/g)

    # TODO add partially specified label to search field
    @sel_view.setItems(labels)
    @sel_view.start te, (item) =>
      te.insertText(item)
      # see if we need to skip a brace
      pt = te.getCursorBufferPosition()
      ran = [[pt.row, pt.column], [pt.row, pt.column+1]]
      if te.getTextInBufferRange(ran) == '}'
        te.moveRight()




  citeComplete: (te) ->

    fname = get_tex_root(te)

    parsed_fname = path.parse(fname)

    filedir = parsed_fname.dir
    filebase = parsed_fname.base  # name only includes the name (no dir, no ext)

    bib_rx = /\\(?:bibliography|nobibliography|addbibresource)\{([^\}]+)\}/g
    raw_bibs = find_in_files(filedir, filebase, bib_rx)

    # Split multiple bib files
    bibs = []
    for b in raw_bibs
      bibs = bibs.concat(b.split(','))

    # Trim and take care of .bib extension
    bibs = for b in bibs
      b = path.resolve(filedir, b) unless path.isAbsolute(b)
      b = b.trim() + '.bib' unless path.extname(b) is '.bib'
      # Check to see if the file exists
      continue unless is_file(b)
      b

    if bibs.length == 0
      atom.notifications.addWarning(
        "Could not find any bib files. " +
        "Please check your \\bibliography statements"
      )
      return

    # If it's a single string, put it in an array
    if typeof bibs == 'string'
      bibs = [bibs]

    bibentries = []
    for b in bibs
      [keywords, titles, authors, years, authors_short, titles_short, journals] = get_bib_completions(b)
      # TODO formatting here
      item_fmt = atom.config.get("latextools.citePanelFormat")

      if item_fmt.length != 2
        atom.notifications.addError(
          "Incorrect citePanelFormat specification. Check your preferences!",
          detail: "Expected 2 entries but got #{item_fmt.length}"
        )
        return

      # Inelegant but safe
      for i in [0...keywords.length]
        primary = item_fmt[0].replace("{keyword}", keywords[i])
          .replace("{title}", titles[i])
          .replace("{author}", authors[i])
          .replace("{year}", years[i])
          .replace("{author_short}", authors_short[i])
          .replace("{title_short}", titles_short[i])
          .replace("{journal}", journals[i])
        secondary = item_fmt[1].replace("{keyword}", keywords[i])
          .replace("{title}", titles[i])
          .replace("{author}", authors[i])
          .replace("{year}", years[i])
          .replace("{author_short}", authors_short[i])
          .replace("{title_short}", titles_short[i])
          .replace("{journal}", journals[i])
        bibentries.push( {"primary": primary, "secondary": secondary, "id": keywords[i]} )

    @sel2_view.setItems(bibentries)
    @sel2_view.start te, (item) =>
      te.insertText(item.id)
      # see if we need to skip a brace
      pt = te.getCursorBufferPosition()
      ran = [[pt.row, pt.column], [pt.row, pt.column+1]]
      if te.getTextInBufferRange(ran) == '}'
        te.moveRight()


  destroy: ->
    @sel2_view.destroy()
    @sel_view.destroy()
