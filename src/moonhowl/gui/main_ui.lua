local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local ui = require "moonhowl.ui"

local main_ui = object:extend()

function main_ui:_init()
    self.tabs = ui.tabbed_container:new()
    self.infobar = ui.info_bar:new()

    self.handle = Gtk.Box{
        id = "main_ui",
        orientation = Gtk.Orientation.VERTICAL,
        spacing = 3,

        self.tabs.handle,
        self.infobar.handle,
    }

    signal.listen("ui_tweet_sent", self.signal_tweet_sent, self)
    signal.listen("ui_message", self.signal_message, self)
end

function main_ui:signal_tweet_sent()
    self.infobar:show "Tweet sent!"
end

function main_ui:signal_message(str, is_err)
    self.infobar:show(str, is_err)
end

return main_ui
