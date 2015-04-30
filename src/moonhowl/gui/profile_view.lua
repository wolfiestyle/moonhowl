local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local ui = require "moonhowl.ui"

local profile_view = object:extend()

function profile_view:_init(user)
    self.user_info = ui.user_view:new(user)
    self.handle = Gtk.ScrolledWindow{
        Gtk.Box{
            id = "profile_view",
            orientation = Gtk.Orientation.VERTICAL,
            margin = 5,
            self.user_info.handle,
        }
    }
    self.handle:show_all()
end

return profile_view
