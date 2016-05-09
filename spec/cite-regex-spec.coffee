{cite_rx_rev} = require '../lib/completion-manager'

matches = [
  '\\cite{'
  '\\cite{abc,'
  '\\cite{abc ,'
  '\\citet{'
  '\\citep{'
  '\\cite*{'
  '\\citet*{'
  '\\citep*{'
  '\\cite[blah]{'
  '\\citet*[blah]{'
  '\\citealt{'
  '\\citealp{'
  '\\citetext{'
  '\\citenum{'
  '\\citeauthor{'
  '\\citeauthor*{'
  '\\citeauthorfull{'
  '\\citeyear{'
  '\\citeyearpar{'
  '\\Cite{'
  '\\Citet{'
  '\\Citep{'
  '\\defcitealias{'
  '\\citetalias{'
  '\\citepalias{'
  '\\Citeauthor{'
  '\\parencite{'
  '\\Parencite{'
  '\\cite[blah][blah]{'
  '\\cite[][]{'
  '\\cite[]{'
  '\\cite[blah][]{'
  '\\cite[][blah]{'
  '\\footcite{'
  '\\footcitetext{'
  '\\textcite{'
  '\\Textcite{'
  '\\smartcite{'
  '\\Smartcite{'
  '\\supercite{'
  '\\Supercite{'
  '\\autocite{'
  '\\Autocite{'
  '\\autocite*{'
  '\\Autocite*{'
  '\\nocite{'
  '\\fullcite{'
  '\\fullcitefullfootcite{'
  '\\volcite{}{'
  '\\Volcite{}{'
  '\\volcite[]{}{'
  '\\volcite{2}{'
  '\\volcite[blah]{2}[64]{'
  '\\pvolcite{}{'
  '\\fvolcite{}{'
  '\\notecite{'
  '\\notecite[][]{'
  '\\notecite[blah blah blah][]{'
  '\\notecite[][blah blah blah]{'
  '\\mancite{'
  '\\textquote['
  '\\textquote*['
  '\\foreigntextquote{}['
  '\\foreigntextquote{german}['
  '\\blockquote['
  '\\foreignblockquote{}['
  '\\hyphenblockquote{}['
  '\\hybridblockquote{}['
  '\\textcquote[][]{'
  '\\textcquote[blah][]{'
  '\\textcquote[][blah]{'
  '\\textcquote{'
  '\\textcquote*[][]{'
  '\\foreigntextcquote{}[][]{'
  '\\foreigntextcquote{}[]{'
  '\\foreigntextcquote{}{'
  '\\foreigntextcquote*{}[][]{'
  '\\hyphentextcquote{}[][]{'
  '\\hyphentextcquote*{}[][]{'
  '\\blockcquote[][]{'
  '\\blockcquote[]{'
  '\\blockcquote{'
  '\\foreignblockcquote{}{'
  '\\foreignblockcquote{}[]{'
  '\\foreignblockcquote{}[][]{'
  '\\hyphenblockcquote{}{'
  '\\hyphenblockcquote{}[]{'
  '\\hyphenblockcquote{}[][]{'
  '\\hybridblockcquote{}{'
  '\\hybridblockcquote{}[]{'
  '\\hybridblockcquote{}[][]{'
  '\\cites{'
  '\\cites[]{'
  '\\cites[][]{'
  '\\cites{}{'
  '\\cites{}[]{'
  '\\cites[]{}[][]{'
  '\\cites(){'
  '\\cites()(){'
  '\\cites()()[][]{'
  '\\cites()()[][]{}{'
  '\\parencites()()[][]{}{'
  '\\volcites()()[]{}[]{'
  '\\cite<e.g.,>[p.~11]{'
  '\\cite<e.g.,>{'
  '\\cite<e.g.,>[p.~11]{abc,'
  '\\citeA<e.g.,>[p.~11]{'
  '\\citeA<e.g.,>[p.~11]{abc,'
  '\\citeyear<e.g.,>[p.~11]{'
  '\\citeyear<e.g.,>[p.~11]{abc,'
  '\\citeyearNP<e.g.,>[p.~11]{'
  '\\citeyearNP<e.g.,>[p.~11]{abc,'
  '\\citeyearNP[p.~11]{'
  '\\citeyearNP[p.~11]{abc,'
  '\\citeNP<e.g.,>[p.~11]{'
  '\\citeNP<e.g.,>[p.~11]{abc,'
  '\\citeNP[p.~11]{abc,'
  '\\citeNP<e.g.,>{abc,'
  '\\maskcite<e.g.,>{abc,'
  '\\fullcite<e.g.,>{abc,'
  '\\shortcite<e.g.,>{abc,'
  '\\maskshortcite<e.g.,>{abc,'
]

non_matches = [
  '\\cite{abc,def'      # no comma
  '\\cite'              # no bracket
  '\\cite{}'            # no open bracket
  '\\cite{abcdef}'      # no open bracket
  '\\citestyle{'        # not a citation command
  '\\volcite{'          # second bracket is citekey
  '\\pvolcite{'         # second bracket is citekey
  '\\volcite[]{'        # second bracket is citekey
  '\\citereset{'        # not a citation command
  '\\citereset*{'       # not a citation command
  '\\mcite{'            # too complex to parse right now
  '\\volcites()()[]{'   # should be a volume number
]

using = (values, func) ->
  for v in values
    v = [v] unless Array.isArray(v)
    func.apply this, v
    jasmine.currentEnv_.currentSpec.description +=
      " \"#{v.join(', ')}\""

describe 'CitationRegex', ->
  using matches, (m) ->
    it 'should match', ->
      expect(cite_rx_rev.exec(m.split("").reverse().join(""))).toBeTruthy()

  using non_matches, (m) ->
    it 'should not match', ->
      expect(cite_rx_rev.exec(m.split("").reverse().join(""))).toBeFalsy()
