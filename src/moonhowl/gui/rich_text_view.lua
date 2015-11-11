local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local entities = require "moonhowl.entities"

local rich_text_view = object:extend()

local selected_for_click

local function tag_event(tag, _, ev)
    if ev:triggers_context_menu() then
        --TODO: select context action
        print("contextual for:", tag.name)
        return true
    end
    if ev.type == "BUTTON_PRESS" then
        if ev.button.button == 1 then  -- at this point the mouse is grabbed
            selected_for_click = tag
        end
    -- detect press and release on the same tag
    elseif ev.type == "BUTTON_RELEASE" and ev.button.button == 1 and selected_for_click == tag then
        return signal.emit("ui_open_uri", tag.name)
    end
end

-- detect mouse ungrab
local function texview_button_release(_, ev)
    if ev.button == 1 then
        selected_for_click = nil
    end
end

-- adds the URI's defined in seg_text as links in the text buffer
local function add_text_tags(buf, seg_text)
    local pos = 0
    local tag_table = buf.tag_table
    for _, elem in ipairs(seg_text) do
        local npos = pos + elem.len
        local tag_name = elem.uri
        if tag_name then
            local tag = tag_table:lookup(tag_name)
            if not tag then
                tag = Gtk.TextTag{ name = tag_name, foreground = "blue" }
                tag.on_event = tag_event
                tag_table:add(tag)
            end
            buf:apply_tag(tag, buf:get_iter_at_offset(pos), buf:get_iter_at_offset(npos))
        end
        pos = npos
    end
end

-- used by Gtk to figure out what tooltip to display
local function tooltip_callback(self, wx, wy, keyboard_mode, tooltip)
    local iter
    if keyboard_mode then
        iter = self.buffer:get_iter_at_offset(self.buffer.cursor_position)
    else
        local x, y = self:window_to_buffer_coords(Gtk.TextWindowType.TEXT, wx, wy)
        iter = self:get_iter_at_location(x, y)
    end

    local _, tag = next(iter:get_tags())
    if tag then
        tooltip:set_text(tag.name)
        tooltip:set_icon_from_stock(Gtk.STOCK_INFO, Gtk.IconSize.MENU)
        return true
    end
end

function rich_text_view:_init()
    self.handle = Gtk.TextView{  --FIXME: set bg color to window bg
        id = "rich_text_view",
        editable = false,
        cursor_visible = false,
        wrap_mode = Gtk.WrapMode.WORD_CHAR,
        has_tooltip = true,
        on_query_tooltip = tooltip_callback,
        hexpand = true,
        on_button_release_event = texview_button_release,
    }
end

function rich_text_view:set_content(obj, field_name, entities_node)
    local cached_name = "_" .. field_name
    local text = obj[cached_name]
    if not text then
        text = entities.parse(obj[field_name], entities_node or obj.entities)
        obj[cached_name] = text
    end

    local buf = self.handle.buffer
    buf:set_text(tostring(text), -1)
    add_text_tags(buf, text)
end

return rich_text_view
