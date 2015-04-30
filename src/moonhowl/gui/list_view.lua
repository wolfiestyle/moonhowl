local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"

local list_view = object:extend()

function list_view:_init()
    self.handle = Gtk.ScrolledWindow{
        Gtk.ListBox{
            id = "list_view",
            selection_mode = "NONE",
        }
    }
    self.list = self.handle.child.list_view
    self.handle:show_all()
end

function list_view:add(obj)
    self.list:add(obj.handle)
end

return list_view
