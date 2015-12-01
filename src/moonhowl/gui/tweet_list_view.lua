local ui = require "moonhowl.ui"
local list_view = ui.list_view

local tweet_list_view = list_view:extend()

tweet_list_view.main_type = "tweet"

function tweet_list_view:_init()
    list_view._init(self)
    self.handle:set_sort_func(self.sort_func)

    local function on_error(err)
        self.loading = false
        return err
    end

    self._on_content_top = {
        ok = function(list)
            self.loading = false
            return self:add_list_top(list)
        end,
        error = on_error,
    }

    self._on_content_bottom = {
        ok = function(list)
            self.loading = false
            -- remove the overlapping tweet on bottom insert
            if self.tail == list[1] then
                table.remove(list, 1)
            end
            return self:add_list_bottom(list)
        end,
        error = on_error,
    }
end

function tweet_list_view:add_list_top(list)
    list._request = nil  -- remove since_id/max_id from the previous request
    self.source_method = function(args)
        return list:_source_method(args)
    end
    return list_view.add_list_top(self, list)
end

function tweet_list_view:add_list_bottom(list)
    list._request = nil  -- remove since_id/max_id from the previous request
    self.source_method = function(args)
        return list:_source_method(args)
    end
    return list_view.add_list_bottom(self, list)
end

function tweet_list_view:refresh()
    print("refresh:", self.source_method)
    if self.source_method and not self.loading then
        self.loading = true
        local first_tw = self.head
        return self.source_method{
            since_id = first_tw and first_tw.id_str,
            _callback = self._on_content_top,
        }
    end
end

function tweet_list_view:on_scroll_bottom()
    print("scroll_bottom:", self.count, self.tail.text)
    if self.source_method and not self.loading then
        self.loading = true
        self.source_method{
            max_id = self.tail.id_str,
            _callback = self._on_content_bottom,
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
