local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"

local tweet_entry = object:extend()

function tweet_entry:_init()
    self.handle = Gtk.Box{
        id = "tweet_entry",
        spacing = 3,
        Gtk.Label{ id = "lbl_chars", label = "0", width_chars = 3 },
        Gtk.Entry{ id = "txt_entry", placeholder_text = "Send a tweet", max_length = 140, hexpand = true }, --FIXME: multiline
        Gtk.Button{ id = "cmd_tweet", label = "Tweet" },
    }

    local child = self.handle.child
    self.lbl_chars = child.lbl_chars
    self.txt_entry = child.txt_entry
    self.cmd_tweet = child.cmd_tweet

    self.txt_entry.on_activate = self:bind(self.txt_entry__on_activate)
    self.cmd_tweet.on_clicked = self:bind(self.cmd_tweet__on_clicked)
end

function tweet_entry:txt_entry__on_activate(widget)
    local text = widget:get_text()
    signal.emit("a_tweet", text, function(tweet)
        self.txt_entry:set_text ""
        return signal.emit("ui_tweet_sent", tweet)
    end)
end

function tweet_entry:cmd_tweet__on_clicked()
    self.txt_entry:activate()
end

return tweet_entry
