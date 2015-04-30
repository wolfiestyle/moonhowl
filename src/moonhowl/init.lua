local ui = require "moonhowl.ui"
local account = require "moonhowl.account"
local http = require "luatwit.http"
local cb_handler = require "moonhowl.cb_handler"

local app = {
    _NAME = arg[0]:match "[^/]+$",
    _VERSION = "scm-1",
}

function app:main()
    self.cb_handler = cb_handler:new(http.service:new())
    self.account = account:new(self.cb_handler):login()
    self.window = ui.main_window:new(self._NAME)
    ui.main_loop()
end

return app
