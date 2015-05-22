local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local ui = require "moonhowl.ui"

local page_container = object:extend()

function page_container:_init()
    self.handle = Gtk.ScrolledWindow{
        id = "page_container",
        --TODO: poner un bg aca
    }

    self.handle:show_all()
end

function page_container:set_child(obj)
    if self.child then
        local child_w = self.handle:get_child() -- actual child can be a Gtk.Viewport
        self.handle:remove(child_w)
    end
    self.child = obj
    self.handle:add(obj.handle)
end

function page_container:add(item)
    return self.child:add(item)
end

local type_to_view = {
    tweet = "tweet_view",
    tweet_list = "tweet_list_view",
    tweet_search = "tweet_search_view",
    user = "profile_view",
    user_list = "user_list_view",
    user_cursor = "user_cursor_view",
}

function page_container:set_content(content, label)
    print("~set_content", label, content)
    self.label:set_text(label)  -- field added by tabbed_view:add
    local view_name = type_to_view[content._type]
    if not view_name then
        view_name = "default_view"
    end
    local view = ui[view_name]:new(content)
    self:set_child(view)
end

return page_container
