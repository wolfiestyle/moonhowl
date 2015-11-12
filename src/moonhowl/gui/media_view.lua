local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local ui = require "moonhowl.ui"

local media_view = object:extend()

function media_view:_init()
    self.handle = Gtk.FlowBox{
        id = "media_view",
        row_spacing = 5,
        column_spacing = 5,
        selection_mode = Gtk.SelectionMode.NONE,
    }
end

function media_view:set_content(media_entities, suffix)
    for _, media in ipairs(media_entities) do
        if media.type == "photo" then
            local size = media.sizes[suffix]
            local img = ui.image_view:new()
            img.handle:set_size_request(size.w, size.h)
            self.handle:add(img.handle)
            img:set_content(media.media_url .. ":" .. suffix)
        end
    end
end

return media_view
