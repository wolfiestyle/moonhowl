local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local ui = require "moonhowl.ui"

local tabbed_view = object:extend()

function tabbed_view:_init()
    self.handle = Gtk.Notebook{
        id = "tabbed_view",
        scrollable = true,
        vexpand = true,
        on_switch_page = self:bind(self.handle__on_switch_page),
    }

    local cmd_new_tab = Gtk.ToolButton{
        icon_name = "list-add",
        on_clicked = signal.bind_emit("ui_new_tab"),
    }
    cmd_new_tab:show()
    self.handle:set_action_widget(cmd_new_tab, Gtk.PackType.END)

    signal.listen("ui_new_tab", self.signal_new_tab, self)
    signal.listen("ui_close_tab", self.signal_close_tab, self)
    signal.listen("ui_set_location", self.signal_set_location, self)
    signal.listen("ui_refresh", self.signal_refresh, self)

    self.child = {}
end

function tabbed_view:add(obj, label_str)
    local label = ui.tab_label:new(obj, label_str)
    obj.label = label
    self.child[obj.handle] = obj
    local id = self.handle:append_page(obj.handle, label.handle)
    self.handle:set_current_page(id)
end

function tabbed_view:remove(widget)
    local id = self.handle:page_num(widget)
    self.handle:remove_page(id)
    local obj = self.child[widget]
    self.child[widget] = nil
    return obj
end

function tabbed_view:get_current_page()
    local id = self.handle:get_current_page()
    local page = self.handle:get_nth_page(id)
    return self.child[page]
end

function tabbed_view:handle__on_switch_page(w, page_w)
    local obj = self.child[page_w]
    signal.emit("ui_set_current_tab", obj)
end

function tabbed_view:signal_new_tab()
    local page = ui.page_container:new()
    self:add(page)
    return page
end

function tabbed_view:signal_close_tab(tab)
    self:remove(tab.handle)
    if self.handle:get_n_pages() == 0 then
        signal.emit("ui_set_current_tab")  -- nil
    end
end

function tabbed_view:signal_set_location(location)
    print("set_location", location.uri)
    local page = self:get_current_page()
    if page ~= nil then
        page.temp_uri = nil
    end
    if page == nil or page.protected then
        page = self:signal_new_tab()
    end
    page.location = location
    signal.emit("ui_set_current_tab", page)
end

function tabbed_view:signal_refresh()
    local page = self:get_current_page()
    if page.location then
        page:location()
    end
end

return tabbed_view
