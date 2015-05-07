local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local ui = require "moonhowl.ui"
local config = require "moonhowl.config"

local main_window = object:extend()

function main_window:_init(title)
    self._title = title
    self.navbar = ui.nav_bar:new()
    self.tabs = ui.tabbed_view:new()
    self.infobar = ui.info_bar:new()
    self.tweet_entry = ui.tweet_entry:new()

    local cw = config.window
    self.handle = Gtk.Window{
        id = "main_window",
        default_width = cw.width,
        default_height = cw.height,
        on_destroy = Gtk.main_quit,
        on_configure_event = self:bind(self.handle__on_configure),

        Gtk.Box{
            orientation = Gtk.Orientation.VERTICAL,
            spacing = 3,

            self.navbar.handle,
            self.tabs.handle,
            self.infobar.handle,
            Gtk.Revealer{
                id = "revealer",
                self.tweet_entry.handle,
            },
        },
    }

    self.revealer = self.handle.child.revealer

    signal.listen("ui_compose", self.signal_compose, self)
    signal.listen("ui_tweet_sent", self.signal_tweet_sent, self)
    signal.listen("ui_message", self.signal_message, self)
    signal.listen("ui_set_current_tab", self.signal_set_current_tab, self)

    signal.emit "ui_new_tab"  -- action widget not visible until a tab is added

    if cw.x and cw.y then
        self.handle:move(cw.x, cw.y)
    end

    self.handle:show_all()
end

function main_window:show_all()
    self.handle:show_all()
end

function main_window:handle__on_configure(w, ev)
    local cw = config.window
    cw.x, cw.y = ev.x, ev.y
    cw.width, cw.height = ev.width, ev.height
end

function main_window:signal_compose()
    self.revealer:set_reveal_child(true)
end

function main_window:signal_tweet_sent(tweet)
    self.revealer:set_reveal_child(false)
    self.infobar:show "Tweet sent!"
end

function main_window:signal_message(str, is_err)
    self.infobar:show(str, is_err)
end

function main_window:signal_set_current_tab(page)
    local uri, title = page and page.location and page.location.uri
    if uri ~= nil and uri ~= "" then
        title = uri .. " - " .. self._title
    else
        title = self._title
    end
    self.handle:set_title(title)
end

return main_window
