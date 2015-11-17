local require = require
require "moonhowl.gui"  -- load our custom namespace

local ui = {
    _prefix = "moonhowl.gui.",
}

local ui_mt = {}

function ui_mt:__index(key)
    local mod = require(self._prefix .. key)
    self[key] = mod
    return mod
end

local type_to_view = {
    tweet = "tweet_view",
    tweet_list = "tweet_list_view",
    tweet_search = "tweet_search_view",
    user = "profile_view",
    user_list = "user_list_view",
    user_cursor = "user_cursor_view",
    dm = "dm_view",
    dm_list = "dm_list_view",
    -- stream messages
    --tweet_deleted = "default_min_view",
    --scrub_geo = "default_min_view",
    --stream_limit = "default_min_view",
    --tweet_withheld = "default_min_view",
    --user_withheld = "default_min_view",
    --stream_disconnect = "default_min_view",
    --stream_warning = "default_min_view",
    --friend_list = "default_min_view",
    --friend_list_str = "default_min_view",
    stream_event = "stream_event_view",
    stream_dm = "dm_view",
}

function ui.view_for(obj, default_name)
    local view_name = type_to_view[obj._type]
    if not view_name then
        print("ui.view_for: unhandled object type:", obj._type)
        view_name = default_name
    end
    local view = ui[view_name]:new()
    view:set_content(obj)
    return view
end

return setmetatable(ui, ui_mt)
