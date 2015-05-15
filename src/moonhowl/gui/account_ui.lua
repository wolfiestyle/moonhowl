local lgi = require "lgi"
local Gtk = lgi.Gtk
local object = require "moonhowl.object"
local config = require "moonhowl.config"
local signal = require "moonhowl.signal"

local account_ui = object:extend()

function account_ui:_init()
    self.handle = Gtk.Box{
        id = "account_ui",
        orientation = Gtk.Orientation.VERTICAL,
        margin = 5,
        spacing = 3,

        Gtk.Label{ label = "<big>Accounts</big>", use_markup = true },
        Gtk.ListBox{
            id = "acc_list",
            selection_mode = "NONE",
            on_row_activated = self.acc_list__row_activated,
        },
        Gtk.Button{
            label = "New account",
            always_show_image = true,
            image = Gtk.Image{ icon_name = "list-add", icon_size = Gtk.IconSize.LARGE_TOOLBAR },
        },
    }
    self.acc_list = self.handle.child.acc_list

    self:init_accounts()
    self.handle:show_all()
end

local function build_acc_row(name)
    return Gtk.Box{
        id = name,
        spacing = 5,
        Gtk.Image{ icon_name = "avatar-default", icon_size = Gtk.IconSize.DIALOG },
        Gtk.Label{ label = name },
    }
end

function account_ui:init_accounts()
    for name, _ in pairs(config.accounts) do
        self.acc_list:add(build_acc_row(name))
    end
end

function account_ui.acc_list__row_activated(w, row)
    signal.emit("ui_login", row:get_child().id)
end

return account_ui
