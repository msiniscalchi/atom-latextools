fs = require 'fs'

module.exports =
get_bib_completions = (bibfile) ->

  completions = []

  kp_rx = /@[^\{]+\{(.+),/
  multi_rx = /\b(author|title|year|editor|journal|eprint)\s*=\s*(?:\{|"|\b)(.+?)(?:\}+|"|\b)\s*,?\s*\Z/i

  try
    bib = fs.readFileSync(bibfile, 'utf-8').split('\n')
  catch error
    alert("cannot read " + bibfile)
    return

    # FIXME from here on, it's Python!

    keywords = []
    titles = []
    authors = []
    years = []
    journals = []

    entry = {   "keyword": "",
                "title": "",
                "author": "",
                "year": "",
                "editor": "",
                "journal": "",
                "eprint": "" }
    for line in bib:
      line = line.strip()
      # Let's get rid of irrelevant lines first
      if line == "" or line[0] == '%':
        continue
      if line.lower()[0:8] == "@comment":
        continue
      if line.lower()[0:7] == "@string":
        continue
      if line.lower()[0:9] == "@preamble":
        continue
      if line[0] == "@":
        # First, see if we can add a record; the keyword must be non-empty, other fields not
        if entry["keyword"]:
          keywords.append(entry["keyword"])
          titles.append(entry["title"])
          years.append(entry["year"])
          # For author, if there is an editor, that's good enough
          authors.append(entry["author"] or entry["editor"] or "????")
          journals.append(entry["journal"] or entry["eprint"] or "????")
          # Now reset for the next iteration
          entry["keyword"] = ""
          entry["title"] = ""
          entry["year"] = ""
          entry["author"] = ""
          entry["editor"] = ""
          entry["journal"] = ""
          entry["eprint"] = ""
        # Now see if we get a new keyword
        kp_match = kp.search(line)
        if kp_match:
          entry["keyword"] = kp_match.group(1)
        else:
          print ("Cannot process this @ line: " + line)
          print ("Previous keyword (if any): " + entry["keyword"])
        continue
      # Now test for title, author, etc.
      # Note: we capture only the first line, but that's OK for our purposes
      multip_match = multip.search(line)
      if multip_match:
        key = multip_match.group(1).lower()     # no longer decode. Was:    .decode('ascii','ignore')
        value = multip_match.group(2)           #                           .decode('ascii','ignore')
          entry[key] = value
      continue

  # at the end, we are left with one bib entry
  keywords.append(entry["keyword"])
  titles.append(entry["title"])
  years.append(entry["year"])
  authors.append(entry["author"] or entry["editor"] or "????")
  journals.append(entry["journal"] or entry["eprint"] or "????")

  print ( "Found %d total bib entries" % (len(keywords),) )

  # # Filter out }'s at the end. There should be no commas left
  titles = [t.replace('{\\textquoteright}', '').replace('{','').replace('}','') for t in titles]

  # format author field
  def format_author(authors):
    # print(authors)
    # split authors using ' and ' and get last name for 'last, first' format
    authors = [a.split(", ")[0].strip(' ') for a in authors.split(" and ")]
    # get last name for 'first last' format (preserve {...} text)
    authors = [a.split(" ")[-1] if a[-1] != '}' or a.find('{') == -1 else re.sub(r'{|}', '', a[len(a) - a[::-1].index('{'):-1]) for a in authors]
    #     authors = [a.split(" ")[-1] for a in authors]
    # truncate and add 'et al.'
    if len(authors) > 2:
      authors = authors[0] + " et al."
    else:
      authors = ' & '.join(authors)
    # return formated string
    # print(authors)
    return authors

  # format list of authors
  authors_short = [format_author(author) for author in authors]

  # short title
  sep = re.compile(":|\.|\?")
  titles_short = [sep.split(title)[0] for title in titles]
  titles_short = [title[0:60] + '...' if len(title) > 60 else title for title in titles_short]
