local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local ui = require "moonhowl.ui"

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

    return table.concat(header, " "),   -- header
           '<small><span color="gray">' .. table.concat(footer, ", ") .. '</span></small>'  -- footer
end

function tweet_view:_init()
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

    local text = ui.rich_text_view:new()

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
    grid:attach(text.handle, 1, 1, 1, 1)
    grid:attach(footer, 1, 4, 1, 1)

    self.handle = grid
    self.icon = icon
    self.header = header
    self.text = text
    self.footer = footer
end

function tweet_view:set_content(tweet)
    self.content = tweet
    local header, footer = parse_tweet(tweet)
    self.header:set_label(header)
    self.footer:set_label(footer)

    local display_tweet = tweet.retweeted_status or tweet
    self.text:set_content(display_tweet, "text")

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
        self.media = ui.media_view:new()
        self.media:set_content(ext.media, "thumb")
        self.handle:attach(self.media.handle, 1, 3, 1, 1)
    end
end

return tweet_view
