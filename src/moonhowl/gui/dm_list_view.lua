local ui = require "moonhowl.ui"
local list_view_scrolled = ui.list_view_scrolled

local dm_list_view = list_view_scrolled:extend()

dm_list_view.main_type = "dm"

function dm_list_view:_init()
    list_view_scrolled._init(self)
    self.handle:set_sort_func(self.sort_func)
end

function dm_list_view.sort_func(ra, rb)
    return rb.priv.content - ra.priv.content
end

return dm_list_view
