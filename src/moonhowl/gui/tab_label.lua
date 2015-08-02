local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"

local tab_label = object:extend()

function tab_label:_init(label_str, close_fn)
    self.close = close_fn
    self.handle = Gtk.EventBox{
        id = "tab_label",
        on_button_press_event = self:bind(self.handle__on_button_press),
        Gtk.Label{
            id = "label",
            label = label_str or "New tab",
        },
    }
    self.label = self.handle.child.label

    self.handle:show_all()
end

function tab_label:set_text(str)
    self.label:set_text(str)
end

function tab_label:handle__on_button_press(_, event)
    if event.button == 2 then
        return self.close()
    end
end

return tab_label
