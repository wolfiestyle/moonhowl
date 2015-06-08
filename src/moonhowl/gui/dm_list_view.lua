local ui = require "moonhowl.ui"
local list_view = ui.list_view

local dm_list_view = list_view:extend()

function dm_list_view:_init(content)
    list_view._init(self)
    self.handle:set_sort_func(self:bind(self.sort_func_id))
    self:add_list(content)
end

function dm_list_view:add_list(list)
    for _, dm in ipairs(list) do
        self:add(ui.dm_view:new(dm))
    end
end

return dm_list_view
