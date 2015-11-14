local ui = require "moonhowl.ui"
local list_view = ui.list_view

local tweet_list_view = list_view:extend()

function tweet_list_view:_init()
    list_view._init(self)
    self.__call = self.sort_func
    self.handle:set_sort_func(self)
end

function tweet_list_view:add_list(list)
    self.content = list  -- last received content
    return self:add_list_of(ui.tweet_view, list)
end

function tweet_list_view:refresh()
    local first_tw = self.content[1]  -- get from sorted list?
    return self.content:_source_method{
        since_id = first_tw and first_tw.id_str,
        _callback = function(list)
            return self:add_list(list)
        end
    }
end

function tweet_list_view:sort_func(ra, rb)
    local obja, objb = ra.priv.content, rb.priv.content
    if obja._type == "tweet" and objb._type == "tweet" then
        return objb - obja    -- sort by tweet id
    else
        return objb._seq_id - obja._seq_id  -- sort by received order
    end
end

return tweet_list_view
