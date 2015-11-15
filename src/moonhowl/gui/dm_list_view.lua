local ui = require "moonhowl.ui"
local list_view = ui.list_view

local dm_list_view = list_view:extend()

function dm_list_view:_init()
    list_view._init(self)
    self.handle:set_sort_func(self.sort_func)
end

function dm_list_view:add_list(list)
    return self:add_list_of(ui.dm_view, list)
end

function dm_list_view.sort_func(ra, rb)
    return rb.priv.content - ra.priv.content
end

return dm_list_view
