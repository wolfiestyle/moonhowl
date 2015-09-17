local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local pretty = require "pl.pretty"

local default_view = object:extend()

function default_view:_init(obj)
    self.handle = Gtk.Label{
        id = "default_view",
        label = pretty.write(obj),
        xalign = 0,
        valign = Gtk.Align.START,
        wrap = true,
        wrap_mode = "WORD_CHAR",
    }
end

return default_view
