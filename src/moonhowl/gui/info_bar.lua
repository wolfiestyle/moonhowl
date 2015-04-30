local lgi = require "lgi"
local Gtk = lgi.Gtk
local GLib = lgi.GLib
local object = require "moonhowl.object"

local info_bar = object:extend()

function info_bar:_init()
    self.handle = Gtk.InfoBar{
        id = "info_bar",
        show_close_button = true,
        no_show_all = true,
    }

    self.lbl_info = Gtk.Label{ wrap = true, wrap_mode = "WORD_CHAR" }
    self.lbl_info:show()
    self.handle:get_content_area():add(self.lbl_info)

    function self._hide()
        return self.handle:hide()
    end
    self.handle.on_response = self:bind(self.handle__on_response)
end

-- displays a message
function info_bar:show(msg, is_error)
    self.lbl_info:set_label(msg)
    self.handle:set_message_type(is_error and Gtk.MessageType.ERROR or Gtk.MessageType.INFO)
    self.handle:show()
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 3000, self._hide)
end

-- handle the builtin close button
function info_bar:handle__on_response(w, resp_id)
    if resp_id == Gtk.ResponseType.CLOSE then
        return self._hide()
    end
end

return info_bar
