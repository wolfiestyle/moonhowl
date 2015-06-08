local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local lt_util = require "luatwit.util"

local list_view = object:extend()

function list_view:_init()
    self.row_ids = {}
    self.handle = Gtk.ListBox{
        id = "list_view",
        selection_mode = "NONE",
    }
    self.list = self.handle.child.list_view
    self.handle:show_all()
end

function list_view:add(obj)
    local row = Gtk.ListBoxRow{ obj.handle, activatable = false, margin = 5 }
    row:show()
    self.row_ids[row] = obj.content.id_str  --FIXME: won't work with mixed object types
    self.list:add(row)
end

function list_view:sort_func_id(ra, rb)
    return lt_util.id_cmp(self.row_ids[rb], self.row_ids[ra])
end

return list_view
