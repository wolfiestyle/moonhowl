local ui = require "moonhowl.ui"
local list_view = ui.list_view

local tweet_search_view = list_view:extend()

function tweet_search_view:set_content(content)
    self:clear()
    return self:add_list(content.statuses)
end

function tweet_search_view:add_list(list)
    return self:add_list_of(ui.tweet_view, list)
end

return tweet_search_view
