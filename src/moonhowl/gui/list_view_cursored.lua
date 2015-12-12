local ui = require "moonhowl.ui"
local list_view = ui.list_view

-- implements cursor based scrolling
local list_view_cursored = list_view:extend()

function list_view_cursored:_init()
    list_view._init(self)
    self.max_size = false

    -- value set by derived classes
    local field, get_list = self.content_field
    if field then
        function get_list(content) return content[field] end
    else
        function get_list(content) return content end
    end
    self._get_list = get_list

    self._on_content_bottom = {
        ok = function(content)
            self.loading = false
            return self:add_list_bottom(content)
        end,
        error = function(err)
            self.loading = false
            return err
        end,
    }
end

function list_view_cursored:add_list_top(content)
    self.last_content = content
    return list_view.add_list_top(self, self._get_list(content))
end

function list_view_cursored:add_list_bottom(content)
    self.last_content = content
    return list_view.add_list_bottom(self, self._get_list(content))
end

function list_view_cursored:on_scroll_bottom()
    print("scroll_bottom:", self.count, self.tail)
    if self.last_content and not self.loading then
        self.loading = true
        return self.last_content:next{
            _callback = self._on_content_bottom,
        }
    end
end

return list_view_cursored
