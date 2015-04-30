local setmetatable = setmetatable

local object = {}
object._class = object

function object:extend()
    local deriv = { __index = self._class }
    deriv._class = deriv
    return setmetatable(deriv, deriv)
end

function object:new(...)
    local obj = { __index = self._class }
    local err = setmetatable(obj, obj):_init(...)
    if err ~= nil then
        return nil, err
    end
    return obj
end

function object._init()
    -- empty
end

function object:bind(fn)
    return function(...)
        return fn(self, ...)
    end
end

function object:bind_1(fn, a1)
    return function(...)
        return fn(self, a1, ...)
    end
end

return object
