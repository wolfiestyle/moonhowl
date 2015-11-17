local ui = require "moonhowl.ui"
local list_view = ui.list_view

local tweet_list_view = list_view:extend()

function tweet_list_view:_init()
    list_view._init(self)
    self.main_type = "tweet"
    self.handle:set_sort_func(self.sort_func)

    self._content_callback = {
        ok = function(list)
            self.loading = false
            -- remove the overlapping tweet on bottom insert
            if self.tail == list[1] then
                table.remove(list, 1)
            end
            return self:add_list(list)
        end,
        error = function(err)
            self.loading = false
            return err
        end,
    }
end

function tweet_list_view:add_list(list)
    list._request = nil  -- remove since_id/max_id from the previous request
    self.source_method = function(args)
        return list:_source_method(args)
    end
    return self:add_list_of(ui.tweet_view, list)
end

function tweet_list_view:refresh()
    if self.source_method and not self.loading then
        self.loading = true
        local first_tw = self.head
        return self.source_method{
            since_id = first_tw and first_tw.id_str,
            _callback = self._content_callback,
        }
    end
end

function tweet_list_view:on_scroll_bottom()
    print("scroll_bottom:", self.count, self.tail.text)
    if self.source_method and not self.loading then
        self.loading = true
        self.source_method{
            max_id = self.tail.id_str,
            _callback = self._content_callback,
        }
    end
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
