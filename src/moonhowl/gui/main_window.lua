local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local ui = require "moonhowl.ui"
local config = require "moonhowl.config"

local main_window = object:extend()

function main_window:_init(title)
    self._title = title
    self.main_ui = ui.main_ui:new()

    local cw = config.window
    self.handle = Gtk.Window{
        id = "main_window",
        default_width = cw.width,
        default_height = cw.height,
        on_destroy = Gtk.main_quit,
        on_configure_event = self.handle__on_configure,

        self.main_ui.handle,
    }

    signal.listen("ui_set_current_tab", self.signal_set_current_tab, self)

    if cw.x and cw.y then
        self.handle:move(cw.x, cw.y)
    end

    self.handle:show_all()
end

function main_window.handle__on_configure(w, ev)
    local cw = config.window
    cw.x, cw.y = ev.x, ev.y
    cw.width, cw.height = ev.width, ev.height
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
