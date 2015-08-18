local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"

local list_view = object:extend()

function list_view:_init()
    self.handle = Gtk.ListBox{
        id = "list_view",
        selection_mode = "NONE",
    }
    self.list = self.handle.child.list_view
end

function list_view:add(obj)
    local row = Gtk.ListBoxRow{ obj.handle, activatable = false, margin = 5 }
    if obj.content then
        self[row] = obj.content
    end
    row:show_all()
    self.list:add(row)
end

return list_view
