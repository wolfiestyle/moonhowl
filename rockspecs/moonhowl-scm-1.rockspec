package = "moonhowl"
version = "scm-1"

source = {
    url = "git://github.com/darkstalker/moonhowl.git",
}

description = {
    summary = "Twitter client written in Lua",
    detailed = [[
        Twitter client written in Lua.
    ]],
    homepage = "https://github.com/darkstalker/moonhowl",
    license = "MPL-2.0",
}

dependencies = {
    "lua >= 5.1",
    "lgi >= 0.9.0",
    "lpeg >= 0.12.2",
    "luatwit >= 0.3.2",
    "luautf8 >= 0.1",
    "penlight >= 1.3.2",
}

build = {
    type = "builtin",
    modules = {
        ["moonhowl.init"] = "src/moonhowl/init.lua"
        --TODO
    },
    install = {
        bin = { moonhowl = "bin/moonhowl" },
    },
}
