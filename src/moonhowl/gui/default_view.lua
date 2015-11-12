local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local pretty = require "pl.pretty"

local default_view = object:extend()

function default_view:_init()
    self.handle = Gtk.Label{
        id = "default_view",
        xalign = 0,
        valign = Gtk.Align.START,
        wrap = true,
        wrap_mode = "WORD_CHAR",
    }
end

function default_view:set_content(obj)
    self.handle:set_label(pretty.write(obj))
end

return default_view
