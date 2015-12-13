local ui = require "moonhowl.ui"
local list_view_scrolled = ui.list_view_scrolled

local dm_list_view = list_view_scrolled:extend()

dm_list_view.main_type = "dm"

function dm_list_view.sort_func(ra, rb)
    return rb.priv.content - ra.priv.content
end

return dm_list_view
