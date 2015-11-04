local lgi = require "lgi"
local Gtk = lgi.Gtk
local utf8 = require "lua-utf8"
local object = require "moonhowl.object"
local ui = require "moonhowl.ui"

local tweet_view = object:extend()

local function escape_amp(text)
    return text:gsub("&", "&amp;")
end

-- replaces t.co URLs with their display_url and fixes the entity indices
local function replace_display_urls(tweet)
    if tweet._text then
        return tweet._text
    end
    -- collect interesting entities
    local entities = {}
    for _, categ in pairs(tweet.entities) do
        if type(categ) == "table" then
            for _, entity in ipairs(categ) do
                if entity.indices then
                    entities[#entities + 1] = entity
                end
            end
        end
    end
    -- we assume that ranges don't overlap, so we can sort them
    table.sort(entities, function(a, b)
        return a.indices[1] < b.indices[1]
    end)
    -- now apply the replacements
    local text = tweet.text
    local buf, pos, offset = {}, 1, 0
    for _, entity in ipairs(entities) do
        local rs, re = unpack(entity.indices)
        local display_url = entity.display_url
        if display_url then
            buf[#buf + 1] = utf8.sub(text, pos, rs) -- before
            buf[#buf + 1] = display_url             -- replaced segment
            pos = re + 1
            -- save the fixed indices
            local dl = utf8.len(display_url) + rs - re  -- length difference
            entity._indices = { rs + offset, re + offset + dl }
            offset = offset + dl
        else
            entity._indices = { rs + offset, re + offset }
        end
    end
    -- save the fixed text
    buf[#buf + 1] = utf8.sub(text, pos, utf8.len(text))
    local newtext = table.concat(buf)
    tweet._text = newtext
    return newtext
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
    return table.concat(header, " "),   -- header
           replace_display_urls(tweet), -- text
           '<small><span color="gray">' .. table.concat(footer, ", ") .. '</span></small>'  -- footer
end

-- uses the entity indices to add links to the text
local function add_text_tags(buf, tweet, categ_desc)
    local tag_table = buf.tag_table
    for name, categ in pairs(tweet.entities) do
        local desc = categ_desc[name]
        if desc then
            local name_field, fmt, event_h = unpack(desc)
            for _, entry in ipairs(categ) do
                local tag_name = fmt:format(entry[name_field])
                local tag = tag_table:lookup(tag_name)
                if not tag then
                    tag = Gtk.TextTag{ name = tag_name, foreground = "blue" } --FIXME: get link color from theme
                    if event_h then
                        tag.on_event = event_h  -- setting nil here will crash
                    end
                    tag_table:add(tag)
                end
                local indices = entry._indices or entry.indices
                buf:apply_tag(tag, buf:get_iter_at_offset(indices[1]), buf:get_iter_at_offset(indices[2]))
            end
        end
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

-- entity_node -> (name_field, uri_format, event_handler)
local entity_categs = {
    media = { "expanded_url", "%s" },
    urls = { "expanded_url", "%s" },
    user_mentions = { "screen_name", "user:%s" },
    hashtags = { "text", "search:%s" },
}

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
    }

    local footer = Gtk.Label{
        id = "footer",
        use_markup = true,
        xalign = 0,
        wrap = true,
        wrap_mode = "WORD_CHAR",
    }

    grid:attach(icon.handle, 0, 0, 1, 2)
    grid:attach(header, 1, 0, 1, 1)
    grid:attach(text, 1, 1, 1, 1)
    grid:attach(footer, 1, 2, 1, 1)

    self.handle = grid
    self.icon = icon
    self.header = header
    self.text = text
    self.footer = footer

    self:set_content(tweet)
end

function tweet_view:set_content(tweet)
    self.content = tweet
    local header, text, footer = parse_tweet(tweet)
    self.header:set_label(header)
    self.footer:set_label(footer)

    local display_tweet = tweet.retweeted_status or tweet
    local buf = self.text.buffer
    buf:set_text(text, -1)
    add_text_tags(buf, display_tweet, entity_categs)

    self.icon:set_content(display_tweet.user.profile_image_url)
end

return tweet_view
