local ui = require "moonhowl.ui"
local list_view_scrolled = ui.list_view_scrolled

local tweet_search_view = list_view_scrolled:extend()

tweet_search_view.main_type = "tweet"
tweet_search_view.content_field = "statuses"

return tweet_search_view
