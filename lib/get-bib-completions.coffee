fs = require 'fs'

module.exports =
get_bib_completions = (bibfile) ->

  completions = []

  kp_rx = /@[^\{]+\{(.+),/
  multi_rx = /\b(author|title|year|editor|journal|eprint)\s*=\s*(?:\{|"|\b)(.+?)(?:\}+|"|\b)\s*,?\s*$/i    # Python's \Z = JS's $

  try
    bib = fs.readFileSync(bibfile, 'utf-8').split('\n')
  catch error
    alert("cannot read " + bibfile)
    return

  keywords = []
  titles = []
  authors = []
  years = []
  journals = []

  entry = {   "keyword": "", "title": "", "author": "", "year": "", "editor": "", "journal": "", "eprint": "" }
  for line in bib
    line = line.trim()
    # Let's get rid of irrelevant lines first
    if line == "" || line[0] == '%'
      continue
    if line.toLowerCase()[0...8] == "@comment"
      continue
    if line.toLowerCase()[0...7] == "@string"
      continue
    if line.toLowerCase()[0...9] == "@preamble"
      continue
    if line[0] == "@"
      # First, see if we can add a record; the keyword must be non-empty, other fields not
      if entry["keyword"]
        keywords.push(entry["keyword"])
        titles.push(entry["title"])
        years.push(entry["year"])
        # For author, if there is an editor, that's good enough
        authors.push(entry["author"] || entry["editor"] || "????")
        journals.push(entry["journal"] || entry["eprint"] || "????")
        # Now reset for the next iteration
        entry["keyword"] = ""
        entry["title"] = ""
        entry["year"] = ""
        entry["author"] = ""
        entry["editor"] = ""
        entry["journal"] = ""
        entry["eprint"] = ""
      # Now see if we get a new keyword
      kp_match = kp_rx.exec(line)
      if kp_match
        # console.log("keyword: #{kp_match[1]}")
        entry["keyword"] = kp_match[1]
      else
        # console.log("Cannot process this @ line: " + line)
        # console.log("Previous keyword (if any): " + entry["keyword"])
      continue
    # Now test for title, author, etc.
    # Note: we capture only the first line, but that's OK for our purposes
    multi_match = multi_rx.exec(line)
    if multi_match
      key = multi_match[1].toLowerCase()
      value = multi_match[2]
      entry[key] = value
      # console.log("key = #{key}: value = #{value}")
    else
      # console.log("no multi_match for line: #{line}")
    continue

  # at the end, we are left with one bib entry
  keywords.push(entry["keyword"])
  titles.push(entry["title"])
  years.push(entry["year"])
  authors.push(entry["author"] || entry["editor"] || "????")
  journals.push(entry["journal"] || entry["eprint"] || "????")

  # console.log( "Found #{keywords.length} total bib entries")

  # # Filter out }'s at the end. There should be no commas left

  # console.log(titles)
  titles = (t.replace('{\\textquoteright}', '').replace(/\{/g,'').replace(/\}/g,'') for t in titles)

  # format author field
  format_author = (authors) ->
    # split authors using ' and ' and get last name for 'last, first' format
    authors = [a.split(", ")[0].trim() for a in authors.split(" and ")]
    # get last name for 'first last' format (preserve {...} text)
    # FIXME: I can't understand what this does!!!!
    ## authors = [if a[-1] != '}' || a.find('{') == -1 then a.split(" ")[-1] else re.sub(r'{|}', '', a[len(a) - a[::-1].index('{'):-1]) for a in authors]
    # truncate and add 'et al.'
    if authors.length > 2
      authors = authors[0] + " et al."
    else
      authors = authors.join(' & ')
    # return formated string
    # print(authors)
    return authors

  # format list of authors
  authors_short = (format_author(author) for author in authors)

  # short title
  sep = /:|\.|\?/

  # console.log(titles)
  titles_short = (title.split(sep)[0] for title in titles)
  titles_short = (if title.length > 40 then title[0...40] + '...' else title for title in titles_short)

  return [keywords, titles, authors, years, authors_short, titles_short, journals]
