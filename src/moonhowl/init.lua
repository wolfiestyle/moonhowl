local ui = require "moonhowl.ui"
local account = require "moonhowl.account"
local http = require "luatwit.http"
local cb_handler = require "moonhowl.cb_handler"
local config = require "moonhowl.config"
local version = require "moonhowl.version"

local app = {}

function app:main()
    config._load()
    self.cb_handler = cb_handler:new(http.service:new())
    self.window = ui.main_window:new(version.app_name)
    self.window:set_child(ui.account_ui:new(self.cb_handler, self.login))
    ui.main_loop()
    config._save()
end

function app.login(acc_name)
    app.account = account:new(app.cb_handler)
    app.account:login(acc_name)
    local main_ui = ui.main_ui:new()
    app.window:set_child(main_ui)
    main_ui.tabs:refresh_all()
end

return app
