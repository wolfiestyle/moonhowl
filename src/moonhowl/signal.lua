local pairs, setmetatable = pairs, setmetatable
local signal = {}

local slots = {}
local slot_mt = { __mode = "v" }

function signal.listen(name, callback, ctx)
    local slot = slots[name]
    if not slot then
        slot = setmetatable({}, slot_mt)
        slots[name] = slot
    end
    slot[callback] = ctx or false
end

function signal.emit(name, ...)
    local slot = slots[name]
    if slot then
        for callback, ctx in pairs(slot) do
            if ctx then
                callback(ctx, ...)
            else
                callback(...)
            end
        end
    end
end

function signal.bind_emit(name)
    return function(...)
        return signal.emit(name, ...)
    end
end

return signal
