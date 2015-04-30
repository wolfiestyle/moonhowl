local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"

local image_view = object:extend()

function image_view:_init()
    self.handle = Gtk.Image{ id = "image_view" }
    self.handle:show()
end

function image_view:set_content(url)
    signal.emit("a_request_image", self, url)
end

function image_view:set_image(image)
    if type(image) == "string" then
        self.handle:set_from_icon_name(image, Gtk.IconSize.DIALOG)
    else
        self.handle:set_from_pixbuf(image)
    end
end

return image_view
