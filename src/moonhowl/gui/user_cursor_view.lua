local ui = require "moonhowl.ui"
local list_view = ui.list_view

local user_cursor_view = list_view:extend()

function user_cursor_view:set_content(content)
    self:clear()
    return self:add_list(content.users)
end

function user_cursor_view:add_list(list)
    return self:add_list_of(ui.user_view, list)
end

return user_cursor_view
