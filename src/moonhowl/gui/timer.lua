local lgi = require "lgi"
local GLib = lgi.GLib

local timer = {}

function timer.add(callback, interval)
    return GLib.timeout_add(GLib.PRIORITY_DEFAULT, interval, callback)
end

return timer
