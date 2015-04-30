local ui = require "moonhowl.ui"
local list_view = ui.list_view

local tweet_search_view = list_view:extend()

function tweet_search_view:_init(content)
    list_view._init(self)
    self:add_list(content.statuses)
end

function tweet_search_view:add_list(list)
    for _, tw in ipairs(list) do
        self:add(ui.tweet_view:new(tw))
    end
end

return tweet_search_view
