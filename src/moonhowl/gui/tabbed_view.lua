local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local ui = require "moonhowl.ui"
local config = require "moonhowl.config"
local location = require "moonhowl.location"

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
    signal.listen("ui_refresh_all", self.signal_refresh_all, self)

    self.child = {}

    self:init_tabs()
    if self.handle:get_n_pages() == 0 then
        self:signal_new_tab()
    end
end

function tabbed_view:add(obj, label_str)
    local label = ui.tab_label:new(obj, label_str)
    obj.label = label
    self.child[obj.handle] = obj
    local id = self.handle:append_page(obj.handle, label.handle)
    self.handle:set_current_page(id)
    config.tabs[id + 1] = false
    return id
end

function tabbed_view:remove(widget)
    local id = self.handle:page_num(widget)
    self.handle:remove_page(id)
    table.remove(config.tabs, id + 1)
    local obj = self.child[widget]
    self.child[widget] = nil
    return obj
end

function tabbed_view:get_current_page()
    local id = self.handle:get_current_page()
    local page = self.handle:get_nth_page(id)
    return self.child[page], id
end

function tabbed_view:init_tabs()
    local cur = config.tabs.current
    for _, uri in ipairs(config.tabs) do
        self:signal_new_tab()
        if uri then
            local loc, err = location:new(uri)
            if loc ~= nil then
                self:signal_set_location(loc)
            else
                io.stderr:write("invalid uri '", uri, "': ", err, "\n")
            end
        end
    end
    if cur then
        self.handle:set_current_page(cur)
    end
end

function tabbed_view:handle__on_switch_page(w, page_w, id)
    local obj = self.child[page_w]
    config.tabs.current = id
    signal.emit("ui_set_current_tab", obj)
end

function tabbed_view:signal_new_tab()
    local page = ui.page_container:new()
    local id = self:add(page)
    return page, id
end

function tabbed_view:signal_close_tab(tab)
    self:remove(tab.handle)
    if self.handle:get_n_pages() == 0 then
        config.tabs.current = nil
        signal.emit("ui_set_current_tab")  -- nil
    end
end

function tabbed_view:signal_set_location(loc)
    print("set_location", loc.uri)
    local page, id = self:get_current_page()
    if page ~= nil then
        page.temp_uri = nil
    end
    if page == nil or page.protected then
        page, id = self:signal_new_tab()
    end
    page.location = loc
    config.tabs[id + 1] = loc.uri
    signal.emit("ui_set_current_tab", page)
end

function tabbed_view:signal_refresh()
    local page = self:get_current_page()
    if page.location then
        page:location()
    end
end

function tabbed_view:signal_refresh_all()
    for _, page in pairs(self.child) do
        if page.location then
            page:location()
        end
    end
end

return tabbed_view
