local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local ui = require "moonhowl.ui"

local tweet_view = object:extend()

local function escape_amp(text)
    return text:gsub("&", "&amp;")
end

-- pango processes HTML entities before anything else, so must escape all the &'s, even in the URL
local function pango_link(text, url)
    return ('<a href="%s">%s</a>'):format(escape_amp(url), escape_amp(text))
end

-- replaces t.co url's with links from entities
local function parse_entities(tweet, with_links)
    local urls = {}
    local fmt = with_links and pango_link or function(x) return x end
    for _, item in ipairs(tweet.entities.urls) do
        local key = item.url:match "https?://t%.co/(%w+)"
        urls[key] = fmt(item.display_url, item.expanded_url)
    end
    if tweet.entities.media then
        for _, item in ipairs(tweet.entities.media) do
            local key = item.url:match "https?://t%.co/(%w+)"
            urls[key] = fmt(item.display_url, item.expanded_url)
        end
    end
    return tweet.text:gsub("https?://t%.co/(%w+)", urls)
end

-- extracts and formats the relevant information from a tweet
local function parse_tweet(tweet, text_only)
    local header, footer = {}, {}
    if tweet.retweeted_status then
        if not text_only then
            header[1] = "🔃" -- symbol for retweets
            local f = "retweeted by @" .. tweet.user.screen_name
            if tweet.retweet_count > 1 then
                f = f .. " and " .. tweet.retweet_count .. " others"
            end
            footer[1] = f
        end
        tweet = tweet.retweeted_status
    end
    if text_only then
        return "<" .. tweet.user.screen_name .. "> " .. parse_entities(tweet)
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
           parse_entities(tweet, true), -- text
           '<small><span color="gray">' .. table.concat(footer, ", ") .. '</span></small>'  -- footer
end

function tweet_view:_init(tweet)
    self.icon = ui.image_view:new()
    self.handle = Gtk.Box{
        id = "tweet_view",
        spacing = 10,
        self.icon.handle,
        Gtk.EventBox{
            id = "content",
            Gtk.Box{
                orientation = Gtk.Orientation.VERTICAL,
                hexpand = true,
                spacing = 5,
                Gtk.Label{ id = "header", use_markup = true, xalign = 0, ellipsize = "END" },
                Gtk.Label{ id = "text", use_markup = true, xalign = 0, vexpand = true, wrap = true, wrap_mode = "WORD_CHAR" },
                Gtk.Label{ id = "footer", use_markup = true, xalign = 0, wrap = true, wrap_mode = "WORD_CHAR" },
            },
        },
    }
    self.icon.handle.valign = Gtk.Align.START
    self.icon.handle.margin_top = 3

    local child = self.handle.child
    self.header = child.header
    self.text = child.text
    self.footer = child.footer

    self:set_content(tweet)
end

function tweet_view:set_content(tweet)
    self.content = tweet
    local header, text, footer = parse_tweet(tweet)
    self.header:set_label(header)
    self.text:set_label(text)
    self.footer:set_label(footer)

    local user = tweet.retweeted_status and tweet.retweeted_status.user or tweet.user
    self.icon:set_content(user.profile_image_url)
end

return tweet_view
