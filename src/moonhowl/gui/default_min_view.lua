local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local ui = require "moonhowl.ui"

local default_min_view = object:extend()

function default_min_view:_init()
    self.child = ui.default_view:new()
    self.handle = Gtk.Expander{
        id = "default_min_view",
        self.child.handle,
    }
end

function default_min_view:set_content(obj)
    self.content = obj
    self.handle:set_label(obj._type)
    self.child:set_content(obj)
end

return default_min_view
