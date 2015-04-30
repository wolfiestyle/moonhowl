local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"

local tab_label = object:extend()

function tab_label:_init(tab, label_str)
    self.tab = tab
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

function tab_label:handle__on_button_press(w, event)
    if event.button == 2 then
        signal.emit("ui_close_tab", self.tab)
    end
end

return tab_label
