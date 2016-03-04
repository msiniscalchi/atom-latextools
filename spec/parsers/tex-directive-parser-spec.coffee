fs = require 'fs'
path = require 'path'
parse_tex_directives = require '../../lib/parsers/tex-directive-parser'

describe 'TeXCommentParser', ->
  beforeEach ->
    waitsForPromise =>
      atom.workspace.open().then (@editor) =>
        @editor = @editor

  describe 'example directives', ->
    it 'should parse root directives', ->
      @editor.insertText("%!TEX root = /root.tex\n")
      result = parse_tex_directives(@editor)
      expect(result.root).toBe '/root.tex'

    it 'should parse program directives', ->
      @editor.insertText("%!TEX program = xelatex\n")
      result = parse_tex_directives(@editor)
      expect(result.program).toBe 'xelatex'

    it 'should parse TS-program directives', ->
      @editor.insertText("%!TEX TS-program = xelatex\n")
      result = parse_tex_directives(
        @editor, keyMaps: {'ts-program': 'program'}
      )
      expect(result.program).toBe 'xelatex'

    it 'should parse option directives', ->
      @editor.insertText("""
        %!TEX options = --shell-escape
        %!TEX options = --draft-mode
      """)
      result = parse_tex_directives(@editor, multiValues: ['options'])
      expect(result.options).toContain '--shell-escape'
      expect(result.options).toContain '--draft-mode'

  describe 'features', ->
    it 'should ignore trailing spaces', ->
      @editor.insertText("%!TEX program = xelatex           \n")
      result = parse_tex_directives(@editor)
      expect(result.program).toBe 'xelatex'

    it 'should allow multiple comment markers', ->
      @editor.insertText("%%%%%%%%%!TEX program = xelatex\n")
      result = parse_tex_directives(@editor)
      expect(result.program).toBe 'xelatex'

    it 'should allow spaces before !TEX', ->
      @editor.insertText("% !TEX program = xelatex\n")
      result = parse_tex_directives(@editor)
      expect(result.program).toBe 'xelatex'

    it 'should work with no spaces around "="', ->
      @editor.insertText("%!TEX program=xelatex\n")
      result = parse_tex_directives(@editor)
      expect(result.program).toBe 'xelatex'

    it 'should accept mix-cased TeX', ->
      @editor.insertText("%!TeX program = xelatex\n")
      result = parse_tex_directives(@editor)
      expect(result.program).toBe 'xelatex'

    it 'should translate directive to lower case', ->
      @editor.insertText("%!TEX PROGRAM = xelatex\n")
      result = parse_tex_directives(@editor)
      expect(result.program).toBe 'xelatex'

    it 'should support multiple directives', ->
      @editor.insertText("""
        %!TEX program = xelatex
        %!TEX options = --shell-escape
      """)
      result = parse_tex_directives(@editor)
      expect(result.program).toBe 'xelatex'
      expect(result.options).toBe '--shell-escape'

    it 'should not find options after the first LaTeX command', ->
      @editor.insertText("""
        %!TEX program = xelatex
        \documentclass{article}
        %!TEX root = root.tex
      """)
      result = parse_tex_directives(@editor)
      expect(result.program).toBe 'xelatex'
      expect(result.root).toBeUndefined

    it 'should allow Windows-style paths', ->
      @editor.insertText("%!TEX root = C:\\Users\\user\\path\\to\\root.tex\n")
      result = parse_tex_directives(@editor)
      expect(result.root).toBe "C:\\Users\\user\\path\\to\\root.tex"

    it 'should not override a previous directive with a latter directive', ->
      @editor.insertText("""
        %!TEX program = xelatex
        %!TEX program = lualatex
      """)
      result = parse_tex_directives(@editor)
      expect(result.program).toBe 'xelatex'

    it 'should allow multivalued directives which do not get overridden', ->
      @editor.insertText("""
        %!TEX options = --shell-escape
        %!TEX options = --draft-mode
      """)
      result = parse_tex_directives(@editor, multiValues: ['options'])
      expect(result.options).toContain '--shell-escape'
      expect(result.options).toContain '--draft-mode'

    it 'should allow a single multivalue directive to be provided as a string', ->
      @editor.insertText("""
        %!TEX options = --shell-escape
        %!TEX options = --draft-mode
      """)
      result = parse_tex_directives(@editor, multiValues: 'options')
      expect(result.options).toContain '--shell-escape'
      expect(result.options).toContain '--draft-mode'

    it 'should allow directives to be renamed', ->
      @editor.insertText("%!TEX TS-program=xelatex\n")
      result = parse_tex_directives(
        @editor, keyMaps: {'ts-program': 'program'}
      )
      expect(result.program).toBe 'xelatex'
      expect(result['ts-program']).toBeUndefined

    it 'should only return values in the onlyFor list', ->
      @editor.insertText("""
        %!TEX program = xelatex
        %!TEX root = ./root.tex
        %!TEX options = --shell-escape
      """)
      result = parse_tex_directives(
        @editor, onlyFor: ['root']
      )
      expect(result.root).toBe = './root.tex'
      expect(result.program).toBeUndefined()
      expect(result.options).toBeUndefined()

    it 'should accept a string as an onlyFor parameter', ->
      @editor.insertText("""
        %!TEX program = xelatex
        %!TEX root = ./root.tex
        %!TEX options = --shell-escape
      """)
      result = parse_tex_directives(@editor, onlyFor: 'root')
      expect(result.root).toBe = './root.tex'
      expect(result.program).toBeUndefined()
      expect(result.options).toBeUndefined()

    it 'should support reading from a file specified as a path', ->
      fixturesPath = path.join atom.project.getPaths()[0], 'parsers', \
        'tex-directive-parser'
      # this is necessary for tests to run locally from symlinked directory
      fixturesPath = fs.realpathSync(fixturesPath)
      testFile = path.join fixturesPath, 'test.tex'
      result = parse_tex_directives(testFile)
      expect(result.program).toBe 'xelatex'
