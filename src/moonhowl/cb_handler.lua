local io_stderr, table_remove, tostring, type =
      io.stderr, table.remove, tostring, type
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local ui = require "moonhowl.ui"

local cb_handler = object:extend()

function cb_handler:_init(http)
    self.http = http
    self.__call = self.add
    self._update = self:bind(self.update)
    self.seq_id = 0
end

function cb_handler:update()
    self.http:update()
    for i = #self, 1, -1 do
        if self[i]() then
            table_remove(self, i)
        end
    end
    return #self > 0
end

function cb_handler:get_id()
    self.seq_id = self.seq_id + 1
    return self.seq_id
end

function cb_handler:add(obj, callback)
    local is_table = type(callback) == "table"

    local updater
    if obj._type == "future" then
        updater = function()
            local ready, res, code_or_err = obj:peek(true)
            if ready then
                if res ~= nil then
                    (is_table and callback.ok or callback)(res, code_or_err)
                else
                    (is_table and callback.error or self.on_error)(code_or_err)
                end
                return true
            end
        end
    elseif obj._type == "stream" then
        updater = function()
            local active, _, err = obj:is_active(true)
            if not active then
                io_stderr:write("cb_handler: stream closed: ", err, "\n")
                if is_table and callback.error then
                    callback.error(err)
                end
                return true
            end
            for data in obj:iter() do
                if type(data) == "table" then
                    data._seq_id = self:get_id();
                    (is_table and callback.ok or callback)(data)
                else
                    (is_table and callback.error or self.on_error)(data)
                end
            end
        end
    else
        return self.on_error "invalid callback object"
    end

    local n = #self
    self[n + 1] = updater
    if n == 0 then
        return ui.timer.add(200, self._update)
    end
end

function cb_handler.on_error(err)
    err = tostring(err)
    io_stderr:write("cb_handler: ", err, "\n")
    return signal.emit("ui_message", err, true)
end

return cb_handler
