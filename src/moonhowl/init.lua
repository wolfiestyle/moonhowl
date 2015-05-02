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
    self.account = account:new(self.cb_handler):login()
    self.window = ui.main_window:new(version.app_name)
    ui.main_loop()
    config._save()
end

return app
