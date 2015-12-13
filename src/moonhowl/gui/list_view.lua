local lgi = require "lgi"
local Gtk = lgi.Gtk
local Moonhowl = lgi.Moonhowl
local object = require "moonhowl.object"
local ui = require "moonhowl.ui"
local fifo = require "moonhowl.fifo"

local list_view = object:extend()

local function ident(arg) return arg end

-- sorted lists: select head/tail by sort order
local function update_sorted(self, content)
    if content and content._type == self.main_type then
        local head, tail = self.head, self.tail
        if not head or content > head then
            self.head = content
        end
        if not tail or content < tail then
            self.tail = content
        end
    end
end

function list_view:_init()
    self.count = 0
    self.buffer = fifo()
    self.max_size = 50

    -- value set by derived classes
    local field = self.content_field
    self._get_list = field and function(content) return content[field] end or ident

    self.handle = Gtk.ListBox{
        id = "list_view",
        selection_mode = "NONE",
        on_size_allocate = self:bind(self.handle__on_size_allocate),
        on_destroy = function()
            if self.cleanup then return self.cleanup() end
        end,
    }

    -- a derived class can define the sort order
    if self.sort_func then
        self.handle:set_sort_func(self.sort_func)
        if self.main_type then
            self._update_head = update_sorted
            self._update_tail = update_sorted
        end
    end
end

local function create_row(obj)
    local row = Moonhowl.ListBoxRow{ obj.handle, activatable = false, margin = 5 }
    row.priv.content = obj.content
    row:show_all()
    return row
end

-- called when adding new content
function list_view:add_top(obj, limit, on_top)
    self.count = self.count + 1  -- limit_size can change the count
    -- add_list will pass this for loop efficiency
    if on_top == nil then
        on_top = self:get_scroll_pos() == 0
    end
    -- if the scrollbar is on top, add the object directly to the container
    if on_top then
        self.handle:prepend(create_row(obj))
        -- also remove excess rows
        if limit then
            self:limit_size()
        end
    else  -- scrollbar not on top, add object to the buffer
        self.buffer.push(obj)
        print("buffered:", self.buffer.count())
    end

    return self:_update_head(obj.content)
end

-- called when scrolling bottom (older content)
function list_view:add_bottom(obj)
    self.count = self.count + 1
    self.handle:add(create_row(obj))
    return self:_update_tail(obj.content)
end

-- unsorted default: last top insert is head
function list_view:_update_head(content)
    if content then
        self.head = content
        if not self.tail then
            self.tail = content
        end
    end
end

-- unsorted default: last bottom insert is tail
function list_view:_update_tail(content)
    if content then
        self.tail = content
        if not self.head then
            self.head = content
        end
    end
end

function list_view:add_list_top(content)
    local list = self._get_list(content)
    local on_top = self:get_scroll_pos() == 0
    for i = #list, 1, -1 do
        local obj = list[i]
        local view = ui.view_for(obj)
        self:add_top(view, nil, on_top)
    end
    if on_top then
        return self:limit_size()
    end
end

function list_view:add_list_bottom(content)
    local list = self._get_list(content)
    for _, obj in ipairs(list) do
        local view = ui.view_for(obj)
        self:add_bottom(view)
    end
end

function list_view:clear()
    if self.count > 0 then
        self.count = 0
        self.buffer = fifo()
        return self.handle:foreach(Gtk.Widget.destroy)
    end
end

function list_view:limit_size(max)
    max = max or self.max_size
    if not max then return end
    -- gtk doesn't seem to have a more efficient way to do this
    local items = self.handle:get_children()
    local n = #items
    if n > max then
        for i = max + 1, n do
            local item = items[i]
            item:destroy()
        end
        self.count = max
        print("deleted:", n - max)
        -- find the last valid tail object (self.main_type)
        if self.main_type then
            for i = max, 1, -1 do
                local item = items[i].priv.content
                if item._type == self.main_type then
                    self.tail = item
                    break
                end
            end
        end
    end
end

function list_view:set_content(list)
    self:clear()
    return self:add_list_bottom(list)
end

function list_view:get_scroll_pos()
    local adj = self.handle:get_adjustment()
    return adj and adj:get_value() or 0
end

-- when scrolling back to top, display all the buffered elements
function list_view:on_scroll_top()
    print(">>scroll_top:", self.count)
    if not self.buffer.empty() then
        self.prev_height = self.handle:get_adjustment().upper  -- received by on_size_allocate
        for obj in self.buffer.iter(10) do
            self.handle:prepend(create_row(obj))
        end
        print("buffer remaining:", self.buffer.count())
    else
        return self:limit_size()
    end
end

-- move the scrollbar so the content stays in the same place after adding things on top
function list_view:handle__on_size_allocate(w)
    if self.prev_height then
        local adj = w:get_adjustment()
        adj:set_value(adj.upper - self.prev_height)
        self.prev_height = nil
        -- we need to do this here, otherwise we get a wrong adj.upper (new size)
        return self:limit_size()
    end
end

return list_view
