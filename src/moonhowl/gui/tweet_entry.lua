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

    self.txt_entry.on_activate = self.txt_entry__on_activate
    self.cmd_tweet.on_clicked = self:bind(self.cmd_tweet__on_clicked)

    signal.listen("ui_tweet_sent", self.signal_tweet_sent, self)
end

function tweet_entry.txt_entry__on_activate(widget)
    local text = widget:get_text()
    signal.emit("a_tweet", nil, text) --FIXME: ctx = current account
end

function tweet_entry:cmd_tweet__on_clicked()
    self.txt_entry:activate()
end

function tweet_entry:signal_tweet_sent()
    self.txt_entry:set_text ""
end

return tweet_entry
