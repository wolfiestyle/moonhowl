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
    }

    local cmd_new_tab = Gtk.ToolButton{
        icon_name = "list-add",
        on_clicked = self:bind(self.cmd_new_tab__clicked),
    }
    cmd_new_tab:show()
    self.handle:set_action_widget(cmd_new_tab, Gtk.PackType.END)

    signal.listen("ui_update_tab", self.signal_update_tab, self)
    signal.listen("ui_new_tab", self.signal_new_tab, self)

    self.child = {}

    self:init_tabs()
    self.handle.on_switch_page = self:bind(self.handle__on_switch_page)

    if self.handle:get_n_pages() == 0 then
        self:new_tab(false)
    end
end

function tabbed_view:add(obj, label_str)
    local label = ui.tab_label:new(label_str, self:bind_1(self.close_tab, obj))
    obj.label = label
    self.child[obj.handle] = obj
    label.handle:show_all()
    obj.handle:show_all()
    local id = self.handle:append_page(obj.handle, label.handle)
    self.handle:set_current_page(id)
    return obj, id
end

function tabbed_view:remove(widget)
    local id = self.handle:page_num(widget)
    self.handle:remove_page(id)
    local close_cb = self.child[widget].cleanup
    self.child[widget] = nil
    if close_cb then
        close_cb()
    end
    return id
end

function tabbed_view:new_tab()
    return self:add(ui.page_container:new())
end

function tabbed_view:init_tabs()
    for _, uri in ipairs(config.tabs) do
        local page = self:new_tab()
        if uri then
            local loc, err = location:new(uri)
            if loc ~= nil then
                page:set_location(loc)
            else
                io.stderr:write("invalid uri '", uri, "': ", err, "\n")
            end
        end
    end
    local cur = config.tabs.current
    if cur then
        self.handle:set_current_page(cur)
    end
end

function tabbed_view:handle__on_switch_page(_, page_w)
    local obj = self.child[page_w]
    return signal.emit("ui_set_current_uri", obj.location and obj.location.uri)
end

function tabbed_view:cmd_new_tab__clicked()
    local _, id = self:new_tab()
    config.tabs[id + 1] = false
end

function tabbed_view:signal_new_tab(uri)
    local loc, err = location:new(uri)
    if loc ~= nil then
        local page, id = self:new_tab()
        page:set_location(loc)
        config.tabs[id + 1] = uri
        return page:refresh()
    else
        return signal.emit("ui_message", err, true)
    end
end

function tabbed_view:close_tab(tab)
    local id = self:remove(tab.handle)
    table.remove(config.tabs, id + 1)
    if self.handle:get_n_pages() == 0 then
        return signal.emit("ui_set_current_uri")  -- nil
    end
end

function tabbed_view:signal_update_tab(page, uri)
    local id = self.handle:page_num(page.handle)
    config.tabs[id + 1] = uri
end

function tabbed_view:refresh_all()
    for _, page in pairs(self.child) do
        page:refresh()
    end
end

return tabbed_view
