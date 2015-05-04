local pretty = require "pl.pretty"
local tablex = require "pl.tablex"
local pl_file = require "pl.file"
local xdg = require "moonhowl.xdg"

local config = {}

local defaults = require "moonhowl.defaults"
setmetatable(config, {
    __index = function(self, key)
        local val = defaults[key]
        if defaults._copy[key] then
            self[key] = val
        end
        return val
    end
})

local config_mt = {}
config_mt.__index = config_mt
setmetatable(defaults, config_mt)

local config_file = xdg.config_dir() .. "config.lua"

function config_mt._load()
    local str = pl_file.read(config_file)
    if str ~= nil then
        tablex.update(config, assert(pretty.read(str)))
    else
        io.stderr:write "Warning: couldn't read config file, using defaults\n"
    end
end

function config_mt._save()
    local str = "-- Auto-generated, do not modify when the app is running\n" ..
                pretty.write(config, "    ") .. "\n"
    assert(pl_file.write(config_file, str))
end

return config
