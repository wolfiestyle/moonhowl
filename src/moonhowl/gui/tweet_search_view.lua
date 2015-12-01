local ui = require "moonhowl.ui"
local list_view = ui.list_view

local tweet_search_view = list_view:extend()

tweet_search_view.main_type = "tweet"

function tweet_search_view:set_content(content)
    return list_view.set_content(self, content.statuses)
end

return tweet_search_view
