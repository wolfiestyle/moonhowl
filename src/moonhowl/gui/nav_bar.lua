local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local location = require "moonhowl.location"

local nav_bar = object:extend()

function nav_bar:_init(parent)
    self.parent = parent
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
            on_clicked = self:bind(self.refresh__on_clicked),
        },
        Gtk.ToolItem{
            id = "addr_container",
            Gtk.Entry{
                id = "addr_bar",
                placeholder_text = "Location or search",
                on_activate = self:bind(self.addr_bar__on_activate),
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
end

function nav_bar:set_location(uri)
    return self.addr_bar:set_text(uri or "")
end

function nav_bar:refresh__on_clicked()
    return self.parent:refresh()
end

function nav_bar:addr_bar__on_activate(widget)
    local loc, err = location:new(widget:get_text())
    if loc == nil then
        return signal.emit("ui_message", err, true)
    end
    local page, uri = self.parent, loc.uri
    page:set_location(loc)
    signal.emit("ui_update_tab", page, uri)
    signal.emit("ui_set_current_uri", uri)
    return page:refresh()
end

function nav_bar:addr_bar__on_key_press_event(_, ev)
    if ev.keyval == 0xff1b then  -- esc
        local page = self.parent
        self:set_location(page.location and page.location.uri)
    end
end

return nav_bar
