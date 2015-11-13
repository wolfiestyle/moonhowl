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

local type_to_view = {
    tweet = "tweet_view",
    --userlist = "userlist_view",
}

function stream_event_view:set_content(ev)
    self.content = ev
    local title = ("* %s: %s -> %s"):format(ev.event, ev.source.screen_name, ev.target.screen_name)
    self.title:set_label(title)

    local obj = ev.target_object
    if obj then
        local view_name = type_to_view[obj._type]
        if not view_name then
            view_name = "default_min_view"
        end
        local view = ui[view_name]:new()
        view:set_content(obj)
        view.handle.opacity = 0.7
        self.handle:add(view.handle)
    end
end

return stream_event_view
