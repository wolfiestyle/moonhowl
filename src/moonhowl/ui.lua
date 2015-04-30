local require = require

local ui = {
    _prefix = "moonhowl.gui.",
}

local ui_mt = {}

function ui_mt:__index(key)
    print("ui: loading " .. key)
    local mod = require(self._prefix .. key)
    self[key] = mod
    return mod
end

return setmetatable(ui, ui_mt)
