local ui = require "moonhowl.ui"
local list_view_cursored = ui.list_view_cursored

local user_cursor_view = list_view_cursored:extend()

user_cursor_view.main_type = "user"
user_cursor_view.content_field = "users"

return user_cursor_view
