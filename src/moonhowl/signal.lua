local pairs, setmetatable = pairs, setmetatable

local slots = {}
local slot_mt = { __mode = "v" }

local function listen(name, callback, ctx)
    local slot = slots[name]
    if not slot then
        slot = setmetatable({}, slot_mt)
        slots[name] = slot
    end
    local fn = ctx and function(...)
        return callback(ctx, ...)
    end or callback
    slot[fn] = ctx or false
end

local function emit(name, ...)
    local slot = slots[name]
    if slot then
        for callback, _ in pairs(slot) do
            callback(...)
        end
    end
end

local function bind_emit(name)
    return function(...)
        return emit(name, ...)
    end
end

return { listen = listen, emit = emit, bind_emit = bind_emit }
