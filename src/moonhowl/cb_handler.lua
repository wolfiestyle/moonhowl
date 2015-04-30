local table_remove, tostring, unpack =
      table.remove, tostring, unpack
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local ui = require "moonhowl.ui"

local cb_handler = object:extend()

function cb_handler:_init(http)
    self.http = http
    self.__call = self.add
    self._update = self:bind(self.update)
end

function cb_handler:update()
    self.http:update()
    for i = #self, 1, -1 do
        local fut, callback = unpack(self[i])
        local ready, res, err = fut:peek(true)
        if ready then
            table_remove(self, i)
            if res == nil then
                self.on_error(err)
            else
                callback(res, err)
            end
        end
    end
    return #self > 0
end

function cb_handler:add(fut, cb)
    local n = #self
    self[n + 1] = { fut, cb }
    if n == 0 then
        ui.timer.add(self._update, 200)
    end
end

function cb_handler.on_error(err)
    signal.emit("ui_message", tostring(err), true)
end

return cb_handler
