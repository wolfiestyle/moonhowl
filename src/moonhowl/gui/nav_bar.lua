local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local location = require "moonhowl.location"

local nav_bar = object:extend()

function nav_bar:_init()
    self.handle = Gtk.Toolbar{
        id = "nav_bar",
        Gtk.ToolButton{
            icon_name = "document-new",
            tooltip_text = "Compose",
            on_clicked = signal.bind_emit("ui_compose")
        },
        Gtk.ToolButton{
            icon_name = "view-refresh",
            tooltip_text = "Refresh",
            on_clicked = signal.bind_emit("ui_refresh")
        },
        Gtk.ToolItem{
            id = "addr_container",
            Gtk.Entry{
                id = "addr_bar",
                placeholder_text = "Location or search",
                on_activate = self:bind(self.addr_bar__on_activate),
                on_changed = self:bind(self.addr_bar__on_change),
                on_key_press_event = self:bind(self.addr_bar__on_key_press_event),
            }
        },
        Gtk.ToolButton{
            id = "menu",
            icon_name = "open-menu-symbolic",
            --on_clicked = self:bind(self.menu__on_clicked),
        },
    }
    self.handle.child.addr_container:set_expand(true)
    self.addr_bar = self.handle.child.addr_bar

    signal.listen("ui_set_current_tab", self.signal_set_current_tab, self)
end

function nav_bar:set_location(uri)
    self.addr_bar:set_text(uri)
    self.uri_changed = false
end

function nav_bar:addr_bar__on_activate(widget)
    local loc, err = location:new(widget:get_text())
    if loc == nil then
        return signal.emit("ui_message", err, true)
    end
    self.uri_changed = false
    signal.emit("ui_set_location", loc)
    signal.emit("ui_refresh")
end

function nav_bar:addr_bar__on_change(widget)
    self.uri_changed = true
end

function nav_bar:addr_bar__on_key_press_event(w, ev)
    if ev.keyval == 0xff1b then  -- esc
        local page = self.current_tab
        if page then
            page.temp_uri = nil
            self:set_location(page.location and page.location.uri or "")
        end
    end
end

function nav_bar:signal_set_current_tab(page)
    if self.current_tab and self.uri_changed then
        self.current_tab.temp_uri = self.addr_bar:get_text()
    end
    self.current_tab = page
    self:set_location(page and (page.temp_uri or page.location and page.location.uri) or "")
end

return nav_bar
