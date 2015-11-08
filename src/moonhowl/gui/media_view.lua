local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local ui = require "moonhowl.ui"

local media_view = object:extend()

function media_view:_init(media_entities, suffix)
    self.suffix = suffix
    self.handle = Gtk.FlowBox{
        id = "media_view",
        row_spacing = 5,
        column_spacing = 5,
        selection_mode = Gtk.SelectionMode.NONE,
    }
    self:set_content(media_entities)
end

function media_view:set_content(media_entities)
    for _, media in ipairs(media_entities) do
        if media.type == "photo" then
            local size = media.sizes[self.suffix]
            local img = ui.image_view:new()
            img.handle:set_size_request(size.w, size.h)
            self.handle:add(img.handle)
            img:set_content(media.media_url .. ":" .. self.suffix)
        end
    end
end

return media_view
