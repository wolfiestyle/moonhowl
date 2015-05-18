local ui = require "moonhowl.ui"
local account = require "moonhowl.account"
local http = require "luatwit.http"
local cb_handler = require "moonhowl.cb_handler"
local config = require "moonhowl.config"
local version = require "moonhowl.version"
local signal = require "moonhowl.signal"

local app = {}

function app:main()
    config._load()
    self.cb_handler = cb_handler:new(http.service:new())
    self.window = ui.main_window:new(version.app_name)
    self.window:set_child(ui.account_ui:new(self.cb_handler))
    signal.listen("ui_login", self.login, self)
    ui.main_loop()
    config._save()
end

function app:login(acc_name)
    self.account = account:new(self.cb_handler)
    self.account:login(acc_name)
    self.window:set_child(ui.main_ui:new())
    signal.emit "ui_refresh_all"
end

return app
