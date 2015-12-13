#!/usr/bin/env lua
local lfs = require "lfs"
local template = require "pl.template"

local rspec_tmpl = [=[
package = "$(project)"
version = "$(version)"

source = {
    url = "git://github.com/darkstalker/$(project).git",
$(tag)}

description = {
    summary = "Twitter client written in Lua",
    detailed = [[
        Twitter client written in Lua.
    ]],
    homepage = "https://github.com/darkstalker/$(project)",
    license = "MPL-2.0",
}

dependencies = {
    "lua >= 5.1",
    "lgi >= 0.9.0",
    "lpeg >= 0.12.2",
    "luatwit >= 0.3.4",
    "luautf8 >= 0.1",
    "penlight >= 1.3.2",
}

build = {
    type = "builtin",
    modules = {
# for _, line in ipairs(modules) do
        ["$(line[1])"] = "$(line[2])",
# end
    },
    install = {
        bin = { moonhowl = "bin/moonhowl" },
    },
}
]=]

local function parse_args()
    local parser = require "argparse" ()
        :description "Generate a rockspec from a template."
    parser:option "--project"
        :description "Project name"
        :default "moonhowl"
    parser:option "--version"
        :description "Release version"
        :default "scm-1"

    return parser:parse()
end

local function tree(path, fn)
    for name in lfs.dir(path) do
        if not name:find "^%." then
            local full = path .. "/" .. name
            local attr = lfs.attributes(full)
            if attr.mode == "file" then
                fn(full)
            elseif attr.mode == "directory" then
                tree(full, fn)
            end
        end
    end
end

local rspec_vars = parse_args()
local mod_lines = {}

lfs.chdir ".."
tree("src", function(file)
    local mod_path = file:match "^src/([^%.]+)%.lua$"
    if mod_path then
        local mod_name = mod_path:gsub("/", ".")
        mod_lines[#mod_lines + 1] = { mod_name, file }
    end
end)

table.sort(mod_lines, function(a, b)
    return a[1] < b[1]
end)

rspec_vars.modules = mod_lines
rspec_vars._parent = _G

local tag = rspec_vars.version:match "^(%d+%.%d+%.%d+)"
if tag then
    rspec_vars.tag = '    tag = "' .. tag .. '",\n'
end

local filename = rspec_vars.project .. "-" .. rspec_vars.version .. ".rockspec"
local out = assert(template.substitute(rspec_tmpl, rspec_vars))
lfs.chdir "rockspecs"
assert(io.open(filename, "w")):write(out)
