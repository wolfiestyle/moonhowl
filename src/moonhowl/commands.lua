local signal = require "moonhowl.signal"

local function location_api(ctx, path, args)
    return signal.emit("a_api_call", ctx, path[1], args)
end

local function location_user(ctx, path, args)
    local n = #path
    if n == 1 and path[2] == nil then
        return signal.emit("a_open_profile", ctx, path[1], args)
    elseif n == 2 and path[1] == "id" then
        return signal.emit("a_open_profile_id", ctx, path[2], args)
    else
        return signal.emit("ui_message", "<screen_name> or id/<user_id> required", true)
    end
end

local function location_tweet(ctx, path, args)
    return signal.emit("a_show_tweet", ctx, path[1], args)
end

local function location_timeline(ctx, path, args)
    return signal.emit("a_timeline", ctx, path[1], path[2], path[3], args)
end

local function location_list(ctx, path, args)
    return signal.emit("a_show_list", ctx, path[1], path[2], args)
end

local function debug_funcs(ctx, path)
    local ui = require "moonhowl.ui"
    local cmd = path[1]
    if cmd == "gc" then
        collectgarbage()
    elseif cmd == "loaded" then
        local names = {}
        for k, v in pairs(ui) do
            if not k:find "^_" then
                names[k] = type(v)
            end
        end
        ctx:set_content("loaded", names)
    elseif cmd == "unload" then
        local name = path[2]
        if not name then
            signal.emit("ui_message", "missing argument", true)
        elseif ui[name] then
            ui[name] = nil
            package.loaded[ui._prefix .. name] = nil
        else
            signal.emit("ui_message", "unknown module " .. name, true)
        end
    else
        signal.emit("ui_message", "invalid debug command", true)
    end
end

return {
    api = { action = location_api, min_args = 1, max_args = 1 },
    user = { action = location_user, min_args = 1, max_args = 2 },
    tweet = { action = location_tweet, min_args = 1, max_args = 1 },
    search = { raw = true, action = signal.bind_emit("a_search") },
    ["search-users"] = { raw = true, action = signal.bind_emit("a_search_users") },
    timeline = { action = location_timeline, min_args = 1, max_args = 3 },
    list = { action = location_list, min_args = 1, max_args = 2 },
    debug = { action = debug_funcs, min_args = 1 },
}
