local twitter = require "luatwit"
local tablex = require "pl.tablex"
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local img_store = require "moonhowl.img_store"
local config = require "moonhowl.config"

local account = object:extend()

function account:_init(cbh)
    self.cb_handler = cbh
    self.client = twitter.api.new(config.app_keys, cbh.http)
    self.client:set_callback_handler(self.cb_handler)

    signal.listen("a_api_call", self.api_call, self)
    signal.listen("a_open_profile", self.open_profile, self)
    signal.listen("a_open_profile_id", self.open_profile_id, self)
    signal.listen("a_show_tweet", self.show_tweet, self)
    signal.listen("a_tweet", self.tweet, self)
    signal.listen("a_search", self.search, self)
    signal.listen("a_search_users", self.search_users, self)
    signal.listen("a_timeline", self.timeline, self)
    signal.listen("a_show_list", self.show_list, self)
    signal.listen("a_request_image", self.request_image, self)
end

function account:login(acct_name)
    if acct_name then
        local acct = config.accounts[acct_name]
        if acct then
            tablex.update(self.client.oauth_config, acct.keys)
        else
            io.stderr:write("Error: account " .. acct_name .. " doesn't exist\n")
        end
    end

    --[[
    self.client:verify_credentials{
        _callback = function(user)
            self.user = user
            signal.emit("ui_message", "logged as " .. user.screen_name)
        end,
    }
    ]]
end

local function _error(msg)
    return signal.emit("ui_message", msg, true)
end

function account:api_call(ctx, method, args)
    local fn = self.client[method]
    if fn == nil then
        return _error("Unknown method: " .. method)
    end
    local handle
    if fn.stream then
        ctx:setup_view("tweet_list_view", method)
        ctx.child.cleanup = function()
            return handle:close()
        end
        args._callback = function(obj)
            return ctx:append_content(obj)
        end
    else
        args._callback = function(obj)
            return ctx:set_content(obj, obj._type)
        end
    end
    handle = fn(self.client, args)
end

local function make_profile(user)
    return { _type = "user_profile", user = user }
end

function account:open_profile(ctx, name, args)
    args.screen_name = name
    args._callback = function(user)
        return ctx:set_content(make_profile(user), "@" .. user.screen_name)
    end
    return self.client:get_user(args)
end

function account:open_profile_id(ctx, id, args)
    args.user_id = id
    args._callback = function(user)
        return ctx:set_content(make_profile(user), "@" .. user.screen_name)
    end
    return self.client:get_user(args)
end

function account:show_tweet(ctx, id, args)
    args.id = id
    args._callback = function(tweet)
        return ctx:set_content(tweet, "tweet")
    end
    return self.client:get_tweet(args)
end

function account:tweet(text, cb, args)
    args = args or {}
    args.status = text
    args._callback = cb
    return self.client:tweet(args)
end

function account:search(ctx, str, args)
    args.q = str
    args._callback = function(res)
        return ctx:set_content(res, "search")
    end
    return self.client:search_tweets(args)
end

function account:search_users(ctx, str, args)
    args.q = str
    args._callback = function(res)
        return ctx:set_content(res, "search")
    end
    return self.client:search_users(args)
end

local function process_list_args(params, id_or_owner, slug)
    if slug then
        params.owner_screen_name = id_or_owner
        params.slug = slug
    elseif id_or_owner then
        params.list_id = id_or_owner
    else
        return _error "<list_id> or <screen_name>/<slug> required"
    end
    return true
end

function account:timeline(ctx, name, id_or_owner, slug, params)
    params._callback = function(tl)
        return ctx:set_content(tl, name)
    end
    if name == "home" then
        return self.client:get_home_timeline(params)
    elseif name == "mentions" then
        return self.client:get_mentions(params)
    elseif name == "list" then
        if process_list_args(params, id_or_owner, slug) then
            return self.client:get_list_timeline(params)
        end
    else
        return _error("Unknown timeline: " .. name)
    end
end

function account:show_list(ctx, id_or_owner, slug, params)
    params._callback = function(tl)
        return ctx:set_content(tl, "list")
    end
    if process_list_args(params, id_or_owner, slug) then
        return self.client:get_list_members(params)
    end
end

function account:request_image(ctx, url)
    local img = img_store.get_cached(url)
    if img then
        return ctx:set_image(img)
    end
    ctx:set_image "image-loading"
    if img == false then    -- request already sent
        return img_store.join_request(url, ctx)
    else
        return self.client:http_request(img_store.new_request(url, ctx))
    end
end

return account
