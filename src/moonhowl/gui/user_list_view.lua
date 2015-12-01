local ui = require "moonhowl.ui"
local list_view = ui.list_view

local user_list_view = list_view:extend()

user_list_view.main_type = "user"

return user_list_view
