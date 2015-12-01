local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local ui = require "moonhowl.ui"

local page_container = object:extend()

function page_container:_init()
    self.navbar = ui.nav_bar:new(self)
    self.handle = Gtk.Box{
        id = "page_container",
        orientation = Gtk.Orientation.VERTICAL,
        spacing = 3,

        self.navbar.handle,
        Gtk.ScrolledWindow{
            id = "scroll_win",
            vexpand = true,
            on_edge_reached = self:bind(self.scroll__on_edge_reached),
        },
    }
    self.container = self.handle.child.scroll_win
end

function page_container:set_child(obj)
    if self.child then
        self.container:get_child():destroy()  -- actual child can be a Gtk.Viewport
    end
    self.child = obj
    obj.handle:show_all()
    return self.container:add(obj.handle)
end

-- prepares the list container for a stream
function page_container:setup_view(view_name, label)
    print("~setup_view", label, view_name)
    self.loaded = nil
    self.label:set_text(label)
    return self:set_child(ui[view_name]:new())
end

-- REST methods will call this
function page_container:set_content(content, label)
    print("~set_content", label, content._type, content._source)
    self.loaded = true
    self.label:set_text(label)
    return self:set_child(ui.view_for(content, "default_view"))
end

-- streaming connections will call this
function page_container:append_content(content)
    return self.child:add_top(ui.view_for(content, "default_min_view"), true)
end

function page_container:set_location(loc)
    self.location = loc
    self.loaded = false
    return self.navbar:set_location(loc.uri)
end

function page_container:refresh()
    if self.location then
        if self.loaded and self.child.refresh then
            return self.child:refresh()
        else
            return self:location()
        end
    end
end

function page_container:scroll__on_edge_reached(_, pos)
    local obj, callback = self.child
    if pos == "BOTTOM" then
        callback = obj.on_scroll_bottom
    elseif pos == "TOP" then
        callback = obj.on_scroll_top
    end
    if callback then
        return callback(obj)
    end
end

return page_container
