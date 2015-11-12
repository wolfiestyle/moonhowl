local ui = require "moonhowl.ui"
local list_view = ui.list_view

local user_list_view = list_view:extend()

function user_list_view:add_list(list)
    return self:add_list_of(ui.user_view, list)
end

return user_list_view
