local twitter = require "luatwit"
local object = require "moonhowl.object"
local signal = require "moonhowl.signal"
local img_store = require "moonhowl.img_store"

local account = object:extend()

function account:_init(cbh)
    self.cb_handler = cbh
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

function account:login()
    local keys = require "pl.config".read(os.getenv "HOME" .. "/.dev-keys")  --FIXME: implementar config
    self.client = twitter.api.new(keys, self.cb_handler.http)
    self.client:set_callback_handler(self.cb_handler)
    --[[
    self.client:verify_credentials{
        _callback = function(user)
            self.user = user
            signal.emit("ui_message", "logged as " .. user.screen_name)
        end,
    }
    ]]
    return self
end

local function _error(msg)
    return signal.emit("ui_message", msg, true)
end

function account:api_call(ctx, method, args)
    local fn = self.client[method]
    if fn == nil then
        return _error("Unknown method: " .. method)
    end
    if fn.stream then
        return _error "Can't call stream methods"
    end
    function args._callback(obj)
        ctx:set_content(obj._type, obj)
    end
    fn(self.client, args)
end

function account:open_profile(ctx, name)
    self.client:get_user{
        screen_name = name,
        _callback = function(user)
            ctx:set_content("@" .. user.screen_name, user)
        end,
    }
end

function account:open_profile_id(ctx, id)
    self.client:get_user{
        user_id = id,
        _callback = function(user)
            ctx:set_content("@" .. user.screen_name, user)
        end,
    }
end

function account:show_tweet(ctx, id)
    self.client:get_tweet{
        id = id,
        _callback = function(tweet)
            ctx:set_content("tweet", tweet)
        end,
    }
end

function account:tweet(ctx, text)
    self.client:tweet{
        status = text,
        _callback = function(tweet)
            signal.emit("ui_tweet_sent", tweet) --FIXME: mandar a home stream
        end,
    }
end

function account:search(ctx, str)
    self.client:search_tweets{
        q = str,
        _callback = function(res)
            ctx:set_content("search", res)
        end,
    }
end

function account:search_users(ctx, str)
    self.client:search_users{
        q = str,
        _callback = function(res)
            ctx:set_content("search", res)
        end,
    }
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

function account:timeline(ctx, name, id_or_owner, slug)
    local params = {
        _callback = function(tl)
            ctx:set_content(name, tl)
        end,
    }
    if name == "home" then
        self.client:get_home_timeline(params)
    elseif name == "mentions" then
        self.client:get_mentions(params)
    elseif name == "list" then
        if process_list_args(params, id_or_owner, slug) then
            self.client:get_list_timeline(params)
        end
    else
        return _error("Unknown timeline: " .. name)
    end
end

function account:show_list(ctx, id_or_owner, slug)
    local params = {
        _callback = function(tl)
            ctx:set_content("list", tl)
        end,
    }
    if process_list_args(params, id_or_owner, slug) then
        self.client:get_list_members(params)
    end
end

function account:request_image(ctx, url)
    local img = img_store.get_cached(url)
    if img then
        return ctx:set_image(img)
    end
    ctx:set_image "image-loading"
    if img == false then    -- request already sent
        img_store.join_request(url, ctx)
    else
        self.client:http_request(img_store.new_request(url, ctx))
    end
end

return account
