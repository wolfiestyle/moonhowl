local ui = require "moonhowl.ui"
local list_view_scrolled = ui.list_view_scrolled

local tweet_list_view = list_view_scrolled:extend()

tweet_list_view.main_type = "tweet"

function tweet_list_view:_init()
    list_view_scrolled._init(self)
    self.handle:set_sort_func(self.sort_func)
end

function tweet_list_view.sort_func(ra, rb)
    local obja, objb = ra.priv.content, rb.priv.content
    if obja._type == "tweet" and objb._type == "tweet" then
        return objb - obja    -- sort by tweet id
    else
        return objb._seq_id - obja._seq_id  -- sort by received order
    end
end

return tweet_list_view
