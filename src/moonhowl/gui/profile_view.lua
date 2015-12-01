local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local ui = require "moonhowl.ui"

local profile_view = object:extend()

function profile_view:_init()
    self.user_info = ui.user_view:new()
    self.handle = Gtk.Box{
        id = "profile_view",
        orientation = Gtk.Orientation.VERTICAL,
        margin = 5,
        self.user_info.handle,
    }
end

function profile_view:set_content(profile)
    self.user_info:set_content(profile.user)
end

return profile_view
