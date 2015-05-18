local lgi = require "lgi"
local Gtk = lgi.Gtk
local twitter = require "luatwit"
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local ui = require "moonhowl.ui"
local config = require "moonhowl.config"

local account_ui = object:extend()

function account_ui:_init(cbh)
    self.state = 0
    self.client = twitter.api.new(config.app_keys, cbh.http)
    self.client:set_callback_handler(cbh)
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
                Gtk.Label{
                    id = "lbl_no_acc",
                    label = "<small>No accounts configured.\nClick the button below to setup one.</small>",
                    use_markup = true,
                    margin = 20,
                    justify = Gtk.Justification.CENTER,
                    no_show_all = true,
                },
                Gtk.ListBox{
                    id = "acc_list",
                    selection_mode = "NONE",
                    on_row_activated = self.acc_list__row_activated,
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
                                margin_left = 10,
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
                            margin_left = 10,
                            Gtk.Label{ label = "<b>Step 2:</b> Sign in with Twitter", use_markup = true, xalign = 0 },
                            Gtk.Box{
                                spacing = 5,
                                margin_left = 10,
                                Gtk.Label{ label = "Auth URL:" },
                                Gtk.LinkButton{ id = "cmd_auth_url", label = "Open in browser" },
                            },
                            Gtk.Box{
                                spacing = 5,
                                margin_left = 10,
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
    self.lbl_no_acc = c.lbl_no_acc
    self.stk_login = c.stk_login
    self.spn1, self.spn2, self.spn3 = c.spn1, c.spn2, c.spn3
    self.cmd_retry1 = c.cmd_retry1
    self.cmd_cancel2 = c.cmd_cancel2
    self.cmd_auth_url = c.cmd_auth_url
    self.pin = c.pin
    self.cmd_confirm = c.cmd_confirm

    self:init_accounts()
    self.handle:show_all()
end

local function build_acc_row(id, name)
    local row = Gtk.Box{
        id = id,
        spacing = 5,
        Gtk.Image{ icon_name = "avatar-default", icon_size = Gtk.IconSize.DIALOG },
        Gtk.Label{ label = name },
    }
    row:show_all()
    return row
end

function account_ui:init_accounts()
    if next(config.accounts) then
        for id, acc in pairs(config.accounts) do
            self.acc_list:add(build_acc_row(id, acc.screen_name))
        end
    else
        self.lbl_no_acc:show()
    end
end

function account_ui:add_account(keys)
    local id, name = keys.user_id, keys.screen_name
    --TODO: check duplicate
    config.accounts[id] = {
        user_id = id,
        screen_name = name,
        keys = {
            oauth_token = keys.oauth_token,
            oauth_token_secret = keys.oauth_token_secret,
        },
    }
    config._save()
    self.acc_list:add(build_acc_row(id, name))
    self.lbl_no_acc:hide()
end

function account_ui.acc_list__row_activated(w, row)
    return signal.emit("ui_login", row:get_child().id)
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
        self.client:oauth_request_token{
            _callback = {
                ok = function(res)
                    self.state = 1
                    return self:next_login_step()
                end,
                error = function(err)
                    self.spn1:stop()
                    self.cmd_retry1:show()
                    return self.infobar:show(err, true)
                end,
            }
        }
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
            _callback = {
                ok = function(token)
                    self.state = 3
                    self.auth_token = token
                    return self:next_login_step()
                end,
                error = function(err)
                    self.spn2:stop()
                    self:_step2_enable(true)
                    return self.infobar:show(err, true)
                end,
            }
        }
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
