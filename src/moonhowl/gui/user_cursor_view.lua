local ui = require "moonhowl.ui"
local list_view = ui.list_view

local user_cursor_view = list_view:extend()

function user_cursor_view:_init(content)
    list_view._init(self)
    self:add_list(content.users)
end

function user_cursor_view:add_list(list)
    for _, user in ipairs(list) do
        self:add(ui.user_view:new(user))
    end
end

return user_cursor_view
