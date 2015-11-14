local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local ui = require "moonhowl.ui"

local stream_event_view = object:extend()

function stream_event_view:_init()
    self.handle = Gtk.Box{
        id = "stream_event_view",
        orientation = Gtk.Orientation.VERTICAL,
        spacing = 3,
        margin_start = 10,
        Gtk.Label{ id = "title", xalign = 0 },
    }
    self.title = self.handle.child.title
end

function stream_event_view:set_content(ev)
    self.content = ev
    local title = ("* %s: %s -> %s"):format(ev.event, ev.source.screen_name, ev.target.screen_name)
    self.title:set_label(title)

    local obj = ev.target_object
    if obj then
        local view = ui.view_for(obj, "default_min_view")
        view.handle.opacity = 0.7
        self.object = view
        self.handle:add(view.handle)
    end
end

return stream_event_view
