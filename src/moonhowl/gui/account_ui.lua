local lgi = require "lgi"
local Gtk = lgi.Gtk
local twitter = require "luatwit"
local object = require "moonhowl.object"
local ui = require "moonhowl.ui"
local config = require "moonhowl.config"

local account_ui = object:extend()

function account_ui:_init(as_h, login_cb)
    self.state = 0
    self.acc_rows = {}
    self.login_cb = login_cb
    self.client = twitter.api.new(config.app_keys, as_h.http)
    self.client:set_async_handler(as_h)
    self._next = self:bind(self.next_login_step)
    self.infobar = ui.info_bar:new()

    self.handle = Gtk.Box{
        id = "account_ui",
        orientation = Gtk.Orientation.VERTICAL,
        margin = 10,
        spacing = 5,

        Gtk.Label{ label = "<big>MoonHowl</big>\n<small>A twitter client in Lua</small>", use_markup = true },
        Gtk.Revealer{
            id = "rev_acc_list",
            reveal_child = true,
            Gtk.Box{
                orientation = Gtk.Orientation.VERTICAL,
                Gtk.Label{
                    label = "<b>Accounts</b>",
                    use_markup = true,
                    xalign = 0,
                    margin_bottom = 5,
                },
                Gtk.ListBox{
                    id = "acc_list",
                    selection_mode = "NONE",
                    on_row_activated = self:bind(self.acc_list__row_activated),
                },
            },
        },
        Gtk.ToggleButton{
            id = "cmd_new_acc",
            label = "New account",
            always_show_image = true,
            image = Gtk.Image{ icon_name = "list-add", icon_size = Gtk.IconSize.LARGE_TOOLBAR },
            on_toggled = self:bind(self.new_acc__on_toggled),
        },
        Gtk.Revealer{
            id = "rev_new_acc",
            transition_type = Gtk.RevealerTransitionType.SLIDE_UP,
            Gtk.Box{
                orientation = Gtk.Orientation.VERTICAL,
                spacing = 15,
                Gtk.Label{ label = "<b>Login</b>", use_markup = true, xalign = 0, margin_bottom = 5 },
                Gtk.Stack{
                    id = "stk_login",
                    transition_type = Gtk.StackTransitionType.SLIDE_UP,
                    {
                        Gtk.Box{
                            orientation = Gtk.Orientation.VERTICAL,
                            Gtk.Box{
                                spacing = 5,
                                margin_start = 10,
                                Gtk.Label{ label = "<b>Step 1:</b> Requesting OAuth token", use_markup = true },
                                Gtk.Button{ id = "cmd_retry1", label = "Retry", on_clicked = self._next },
                                Gtk.Spinner{ id = "spn1" },
                            },
                        },
                        name = "step_1",
                    },
                    {
                        Gtk.Box{
                            orientation = Gtk.Orientation.VERTICAL,
                            spacing = 5,
                            margin_start = 10,
                            Gtk.Label{ label = "<b>Step 2:</b> Sign in with Twitter", use_markup = true, xalign = 0 },
                            Gtk.Box{
                                spacing = 5,
                                margin_start = 10,
                                Gtk.Label{ label = "Auth URL:" },
                                Gtk.LinkButton{ id = "cmd_auth_url", label = "Open in browser" },
                            },
                            Gtk.Box{
                                spacing = 5,
                                margin_start = 10,
                                Gtk.Entry{ id = "pin", placeholder_text = "Enter PIN", on_activate = self._next },
                                Gtk.Button{ id = "cmd_confirm", label = "Confirm", on_clicked = self._next },
                                Gtk.Button{ id = "cmd_cancel2", label = "Cancel", on_clicked = self:bind(self.cancel_login) },
                                Gtk.Spinner{ id = "spn2" },
                            },
                        },
                        name = "step_2",
                    },
                },
            },
        },
        self.infobar.handle,
    }
    local c = self.handle.child
    self.acc_list = c.acc_list
    self.rev_acc_list = c.rev_acc_list
    self.rev_new_acc = c.rev_new_acc
    self.cmd_new_acc = c.cmd_new_acc
    self.stk_login = c.stk_login
    self.spn1, self.spn2, self.spn3 = c.spn1, c.spn2, c.spn3
    self.cmd_retry1 = c.cmd_retry1
    self.cmd_cancel2 = c.cmd_cancel2
    self.cmd_auth_url = c.cmd_auth_url
    self.pin = c.pin
    self.cmd_confirm = c.cmd_confirm

    local lbl_no_acc = Gtk.Label{
        label = "<small>No accounts configured.\nClick the button below to setup one.</small>",
        use_markup = true,
        margin = 20,
        justify = Gtk.Justification.CENTER,
        no_show_all = true,
    }
    lbl_no_acc:show()
    self.acc_list:set_placeholder(lbl_no_acc)

    self:init_accounts()
end

function account_ui:build_acc_row(id, name)
    local menu = Gtk.Menu{
        Gtk.MenuItem{ label = name, sensitive = false },
        Gtk.SeparatorMenuItem(),
        Gtk.MenuItem{ id = "delete", label = "Delete", on_activate = self:bind_1(self.remove_account, id) },
    }
    menu:show_all()
    local row = Gtk.ListBoxRow{
        id = id,
        Gtk.EventBox{
            visible_window = false,
            on_button_press_event = self.bind(menu, self.acc_list__on_button_press),  -- ugly
            Gtk.Box{
                spacing = 5,
                Gtk.Image{ icon_name = "avatar-default", icon_size = Gtk.IconSize.DIALOG },
                Gtk.Label{ label = name },
            }
        }
    }
    row:show_all()
    self.acc_rows[id] = row
    return row
end

function account_ui:init_accounts()
    for id, acc in pairs(config.accounts) do
        self.acc_list:add(self:build_acc_row(id, acc.screen_name))
    end
end

function account_ui:add_account(keys)
    local id, name = keys.user_id, keys.screen_name
    config.accounts[id] = {
        user_id = id,
        screen_name = name,
        keys = {
            oauth_token = keys.oauth_token,
            oauth_token_secret = keys.oauth_token_secret,
        },
    }
    config._save()
    local old = self.acc_rows[id]
    if old then
        self.acc_list:remove(old)
    end
    self.acc_list:add(self:build_acc_row(id, name))
end

function account_ui:remove_account(id)
    self.acc_list:remove(self.acc_rows[id])
    self.acc_rows[id] = nil
    config.accounts[id] = nil
    config._save()
end

function account_ui:acc_list__row_activated(_, row)
    return self.login_cb(row.id)
end

function account_ui.acc_list__on_button_press(menu, _, event)
    if event:triggers_context_menu() then
        return menu:popup(nil, nil, nil, nil, event.button, event.time)
    end
end

function account_ui:new_acc__on_toggled(w)
    local active = w:get_active()
    self.rev_acc_list:set_reveal_child(not active)
    self.rev_new_acc:set_reveal_child(active)
    if active and self.state == 0 then
        return self:next_login_step()
    end
end

function account_ui:next_login_step()
    local state = self.state
    if state == 0 then -- request token
        self.cmd_retry1:hide()
        self.stk_login:set_visible_child_name "step_1"
        self.spn1:start()
        local oc = self.client.oauth_config
        oc.oauth_token = nil
        oc.oauth_token_secret = nil
        self.client:oauth_request_token{ _async = true }:map(function(res, err)
            if res == nil then
                self.spn1:stop()
                self.cmd_retry1:show()
                self.infobar:show(err, true)
                return true
            end
            self.state = 1
            self:next_login_step()
            return true
        end)
    elseif state == 1 then -- show auth url
        self.state = 2
        self.spn1:stop()
        self.pin:set_text ""
        self:_step2_enable(true)
        self.cmd_auth_url:set_uri(self.client:oauth_authorize_url())
        self.stk_login:set_visible_child_name "step_2"
    elseif state == 2 then -- process pin
        self.spn2:start()
        self:_step2_enable(false)
        self.client:oauth_access_token{
            oauth_verifier = self.pin:get_text(),
            _async = true,
        }
        :map(function(token, err)
            if token == nil then
                self.spn2:stop()
                self:_step2_enable(true)
                self.infobar:show(err, true)
                return true
            end
            self.state = 3
            self.auth_token = token
            self:next_login_step()
            return true
        end)
    elseif state == 3 then -- done
        self.state = 0
        self.spn2:stop()
        self:add_account(self.auth_token)
        self.auth_token = nil
        self.cmd_new_acc:set_active(false)
    end
end

function account_ui:_step2_enable(val)
    self.pin:set_sensitive(val)
    self.cmd_confirm:set_sensitive(val)
    self.cmd_cancel2:set_sensitive(val)
end

function account_ui:cancel_login()
    self.state = 0
    self.cmd_new_acc:set_active(false)
end

return account_ui
