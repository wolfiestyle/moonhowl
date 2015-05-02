local lfs = require "lfs"
local version = require "moonhowl.version"

local _M = {}

local function get_home_dir()
    local home = os.getenv "HOME"
    if home == nil then
        io.stderr:write "Warning: could not find $HOME, using current dir instead\n"
        home = assert(lfs.currentdir())
    end
    return home
end

local function mkdir(dir)
    local mode = lfs.attributes(dir, "mode")
    if mode == nil then
        assert(lfs.mkdir(dir))
    elseif mode ~= "directory" then
        error(dir .. " already exists as a " .. mode)
    end
end

local function get_xdg_dir(env_name, dir_name, app_name)
    local base = os.getenv(env_name)
    if base == nil then
        local home = get_home_dir()
        base = home .. dir_name
        mkdir(base)
    end
    local dir = ("%s/%s/"):format(base, app_name)
    mkdir(dir)
    return dir
end

function _M.config_dir()
    return get_xdg_dir("XDG_CONFIG_HOME", "/.config", version.app_name)
end

function _M.cache_dir()
    return get_xdg_dir("XDG_CACHE_HOME", "/.cache", version.app_name)
end

return _M
