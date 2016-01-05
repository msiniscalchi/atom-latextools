{LTool,get_tex_root} = require './ltutils'
LTSelectListView = require './ltselectlist-view'
# {exec} = require 'child_process'
path = require 'path'
fs = require 'fs'

module.exports =

class CompletionManager extends LTool

  ref_complete: ->

    @sel_view = new LTSelectListView

    @sel_view.show()
