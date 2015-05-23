local object = require "moonhowl.object"
local commands = require "moonhowl.commands"

local location = object:extend()

local patt_uri, patt_args
do
    local lpeg = require "lpeg"
    local C, Cf, Cg, Ct, P, R, S = lpeg.C, lpeg.Cf, lpeg.Cg, lpeg.Ct, lpeg.P, lpeg.R, lpeg.S

    local function append(acc, k, v)
        acc[k] = v or true
        return acc
    end

    local alpha = R"AZ" + R"az"
    local alnum = alpha + R"09"
    local space = P" "
    local str = P(1)^0

    local ident = (alnum + "_")^1
    local user = P"@"/"user" * C(ident) * space^0
    local scheme = C( alpha * (alnum + S"+-.")^0 ) * ":"
    local uri = user + scheme * C(str)

    local psep = P"/"
    local qst = P"?"
    local dir = C( (1 - (psep + qst))^1 )
    local path = Ct( (dir * psep^-1)^0 )

    local fsep = P"="
    local qsep = P"&"
    local key = C( (1 - (fsep + qsep))^1 )
    local val = C( (1 - qsep)^0 )
    local field = Cg( key * (fsep * val)^-1 )
    local query = qst * Cf( Ct"" * (field * qsep^-1)^0, append )

    patt_uri = uri * -1
    patt_args = path * query^-1 * -1
end

function location:_init(uri)
    local cmd, args = patt_uri:match(uri)
    if cmd ~= nil then
        return self:_parse_command(cmd, args)
    else
        return self:_parse_command("search", uri)
    end
end

function location:_parse_command(name, args)
    local cmd = commands[name]
    if not cmd then
        return "Invalid scheme: " .. name
    end
    local path, query
    if not cmd.raw then
        path, query = patt_args:match(args)
        if path == nil then
            return "Invalid URI"
        end
        local n, min, max = #path, cmd.min_args, cmd.max_args
        if min and n < min then
            return "Too few arguments (>= " .. min .. " expected)"
        end
        if max and n > max then
            return "Too many arguments (<= " .. max .. " expected)"
        end
    else
        path = args
    end

    self.uri = name .. ":" .. args
    self.path = path
    self.query = query or {}
    self.action = cmd.action
    self.__call = self.run
end

function location:run(ctx)
    return self.action(ctx, self.path, self.query)
end

return location
