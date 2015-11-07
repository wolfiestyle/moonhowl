local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"

local image_view = object:extend()

function image_view:_init()
    self.handle = Gtk.EventBox{
        id = "image_view",
        visible_window = false,
        Gtk.Image{ id = "image" },
    }
    self.image = self.handle.child.image
end

function image_view:set_content(url)
    return signal.emit("a_request_image", self, url)
end

function image_view:set_image(image)
    if type(image) == "string" then
        return self.image:set_from_icon_name(image, Gtk.IconSize.DIALOG)
    else
        return self.image:set_from_pixbuf(image)
    end
end

-- no on_clicked event for EventBox so we have to implement it manually
function image_view:_install_click_handler()
    local selected, inside
    self.handle.on_button_press_event = function(_, ev)
        if ev.button == 1 then
            selected = true
        end
    end
    self.handle.on_button_release_event = function(obj, ev)
        if ev.button == 1 then
            if selected and inside then
                self.on_clicked(obj, ev)
            end
            selected = false
        end
    end
    self.handle.on_enter_notify_event = function()
        inside = true
    end
    self.handle.on_leave_notify_event = function()
        inside = false
    end
end

function image_view:set_on_clicked(callback)
    if self._install_click_handler then
        self:_install_click_handler()
        self._install_click_handler = false
    end
    self.on_clicked = callback
end

return image_view
