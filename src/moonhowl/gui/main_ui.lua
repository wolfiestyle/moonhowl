local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local ui = require "moonhowl.ui"

local main_ui = object:extend()

function main_ui:_init()
    self.tabs = ui.tabbed_container:new()
    self.infobar = ui.info_bar:new()
    self.tweet_entry = ui.tweet_entry:new()

    self.handle = Gtk.Box{
        id = "main_ui",
        orientation = Gtk.Orientation.VERTICAL,
        spacing = 3,

        self.tabs.handle,
        self.infobar.handle,
        Gtk.Revealer{
            id = "revealer",
            self.tweet_entry.handle,
        },
    }

    self.revealer = self.handle.child.revealer

    signal.listen("ui_compose", self.signal_compose, self)
    signal.listen("ui_tweet_sent", self.signal_tweet_sent, self)
    signal.listen("ui_message", self.signal_message, self)
end

function main_ui:signal_compose()
    self.revealer:set_reveal_child(true)
end

function main_ui:signal_tweet_sent()
    self.revealer:set_reveal_child(false)
    self.infobar:show "Tweet sent!"
end

function main_ui:signal_message(str, is_err)
    self.infobar:show(str, is_err)
end

return main_ui
