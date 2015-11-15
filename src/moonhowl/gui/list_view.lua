local lgi = require "lgi"
local Gtk = lgi.Gtk
local Moonhowl = lgi.Moonhowl
local object = require "moonhowl.object"

local list_view = object:extend()

function list_view:_init()
    self.count = 0
    self.handle = Gtk.ListBox{
        id = "list_view",
        selection_mode = "NONE",
    }
end

function list_view:add(obj)
    local row = Moonhowl.ListBoxRow{ obj.handle, activatable = false, margin = 5 }
    local content = obj.content
    if content then
        row.priv.content = content
        if content._type == self.main_type then
            if not self.head or content > self.head then
                self.head = content
            end
            if not self.tail or content < self.tail then
                self.tail = content
            end
        end
    end
    self.count = self.count + 1
    row:show_all()
    return self.handle:add(row)
end

function list_view:add_list_of(class, list)
    for _, obj in ipairs(list) do
        local view = class:new()
        view:set_content(obj)
        self:add(view)
    end
end

function list_view:clear()
    if self.count > 0 then
        self.count = 0
        return self.handle:foreach(Gtk.Widget.destroy)
    end
end

function list_view:set_content(list)
    self:clear()
    return self:add_list(list)  -- implemented in subclasses
end

return list_view
