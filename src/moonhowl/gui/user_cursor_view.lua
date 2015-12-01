local ui = require "moonhowl.ui"
local list_view = ui.list_view

local user_cursor_view = list_view:extend()

user_cursor_view.main_type = "user"

function user_cursor_view:set_content(content)
    return list_view.set_content(self, content.users)
end

return user_cursor_view
