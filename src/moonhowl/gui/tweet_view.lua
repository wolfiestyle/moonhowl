local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local ui = require "moonhowl.ui"
local entities = require "moonhowl.entities"

local tweet_view = object:extend()

local function escape_amp(text)
    return text:gsub("&", "&amp;")
end

-- extracts and formats the relevant information from a tweet
local function parse_tweet(tweet)
    local header, footer = {}, {}
    if tweet.retweeted_status then
        header[1] = "🔃" -- symbol for retweets
        local f = "retweeted by @" .. tweet.user.screen_name
        if tweet.retweet_count > 1 then
            f = f .. " and " .. tweet.retweet_count .. " others"
        end
        footer[1] = f
        tweet = tweet.retweeted_status
    end
    header[#header + 1] = "<b>" .. tweet.user.screen_name .. "</b>"
    if tweet.user.protected then
        header[#header + 1] = "🔒" -- symbol for locked accounts
    end
    header[#header + 1] = '<span color="gray">' .. escape_amp(tweet.user.name) .. '</span>'
    if tweet.in_reply_to_screen_name then
        footer[#footer + 1] = "in reply to @" .. tweet.in_reply_to_screen_name
    end
    footer[#footer + 1] = "via " .. tweet.source:gsub('rel=".*"', '') -- it's a valid link, but pango chokes with the extra attribute

    local text = tweet._text
    if not text then
        text = entities.parse(tweet.text, tweet.entities)
        tweet._text = text
    end

    return table.concat(header, " "),   -- header
            text,   -- segmented text
           '<small><span color="gray">' .. table.concat(footer, ", ") .. '</span></small>'  -- footer
end

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

function tweet_view:_init(tweet)
    local grid = Gtk.Grid{
        id = "tweet_view",
        row_spacing = 5,
        column_spacing = 5,
    }

    local icon = ui.image_view:new()
    icon.handle.valign = Gtk.Align.START
    icon.handle.margin_top = 3

    local header = Gtk.Label{
        id = "header",
        use_markup = true,
        xalign = 0,
        ellipsize = "END",
    }

    local text = Gtk.TextView{  --FIXME: set bg color to window bg
        id = "text",
        editable = false,
        cursor_visible = false,
        wrap_mode = Gtk.WrapMode.WORD_CHAR,
        has_tooltip = true,
        on_query_tooltip = tooltip_callback,
        hexpand = true,
        on_button_release_event = texview_button_release,
    }

    local footer = Gtk.Label{
        id = "footer",
        use_markup = true,
        xalign = 0,
        wrap = true,
        wrap_mode = "WORD_CHAR",
    }

    -- rows: 0=header, 1=text, 2=quoted, 3=media, 4=footer
    grid:attach(icon.handle, 0, 0, 1, 2)
    grid:attach(header, 1, 0, 1, 1)
    grid:attach(text, 1, 1, 1, 1)
    grid:attach(footer, 1, 4, 1, 1)

    self.handle = grid
    self.icon = icon
    self.header = header
    self.text = text
    self.footer = footer

    self:set_content(tweet)
end

function tweet_view:set_content(tweet)
    self.content = tweet
    local header, seg_text, footer = parse_tweet(tweet)
    self.header:set_label(header)
    self.footer:set_label(footer)

    local buf = self.text.buffer
    buf:set_text(tostring(seg_text), -1)
    add_text_tags(buf, seg_text)

    local display_tweet = tweet.retweeted_status or tweet
    local user_uri = "user:" .. display_tweet.user.screen_name
    self.icon.handle.tooltip_text = user_uri
    self.icon:set_on_clicked(function()
        return signal.emit("ui_open_uri", user_uri)
    end)
    self.icon.handle.on_button_press_event = function(_, ev)
        if ev:triggers_context_menu() then
            print("contextual for:", user_uri)  --TODO
            return true
        end
    end

    if tweet.quoted_status then
        self.quoted = tweet_view:new(tweet.quoted_status)
        local quoted = self.quoted.handle
        quoted.margin = 5
        self.handle:attach(Gtk.Frame{ quoted }, 1, 2, 1, 1)
    end

    self.icon:set_content(display_tweet.user.profile_image_url)

    local ext = tweet.extended_entities
    if ext and ext.media and next(ext.media) then
        self.media = ui.media_view:new(ext.media, "thumb")
        self.handle:attach(self.media.handle, 1, 3, 1, 1)
    end
end

return tweet_view
