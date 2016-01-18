local ui = require "moonhowl.ui"
local list_view = ui.list_view

-- implements since_id/max_id based scrolling
local list_view_scrolled = list_view:extend()

function list_view_scrolled:_init()
    list_view._init(self)

    self._on_content_top = function(content, err)
        self.loading = false
        if content == nil then return nil, err end
        self:add_list_top(content)
        return content
    end

    self._on_content_bottom = function(content, err)
        self.loading = false
        if content == nil then return nil, err end
        -- remove the overlapping element on bottom insert
        local list = self._get_list(content)
        if self.tail == list[1] then
            table.remove(list, 1)
        end
        self:add_list_bottom(content)
        return content
    end
end

local function pre_add_common(self, content)
    local req = content._request
    if req then
        req.since_id = nil
        req.max_id = nil
    end
    self.last_content = content
end

function list_view_scrolled:add_list_top(content)
    pre_add_common(self, content)
    return list_view.add_list_top(self, content)
end

function list_view_scrolled:add_list_bottom(content)
    pre_add_common(self, content)
    return list_view.add_list_bottom(self, content)
end

function list_view_scrolled:refresh()
    print("refresh:", self.last_content)
    if self.last_content and not self.loading then
        self.loading = true
        local first_tw = self.head
        return self.last_content:_source_method{
            since_id = first_tw and first_tw.id_str,
            _async = true,
        }
        :map(self._on_content_top)
    end
end

function list_view_scrolled:on_scroll_bottom()
    print("scroll_bottom:", self.count, self.tail.text)
    if self.last_content and not self.loading then
        self.loading = true
        return self.last_content:_source_method{
            max_id = self.tail.id_str,
            _async = true,
        }
        :map(self._on_content_bottom)
    end
end

return list_view_scrolled
