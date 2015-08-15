local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local ui = require "moonhowl.ui"

local default_min_view = object:extend()

function default_min_view:_init(obj)
    self.content = obj
    self.child = ui.default_view:new(obj)
    self.handle = Gtk.Expander{
        id = "default_min_view",
        label = obj._type,
        self.child.handle,
    }
    self.handle:show_all()
end

return default_min_view
