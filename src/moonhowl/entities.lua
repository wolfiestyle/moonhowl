local ipairs, pairs, setmetatable, table_concat, table_sort =
      ipairs, pairs, setmetatable, table.concat, table.sort
local utf8 = require "lua-utf8"

local unpack = table.unpack or unpack

local html_entities = {
    amp = "&",
    lt = "<",
    gt = ">",
}

local function unescape(text)
    return text:gsub("&(%w+);", html_entities)
end

-- entity_node -> (name_field, uri_format)
local entity_categs = {
    media = { "expanded_url", "%s" },
    urls = { "expanded_url", "%s" },
    user_mentions = { "screen_name", "user:%s" },
    hashtags = { "text", "search:%s" },
    --symbols = not interesting...
}

local segmented_text_mt = {}

function segmented_text_mt:__tostring()
    local as_str = self.as_str
    if as_str then return as_str end
    local buf = {}
    for i = 1, #self do
        local item = self[i]
        buf[i] = item.text
    end
    as_str = table_concat(buf)
    self.as_str = as_str
    return as_str
end

-- splits the text into segments delimited by the entities
local function parse_entities(text, entities_node)
    -- collect all entities
    local entities = {}
    for name, _ in pairs(entity_categs) do
        local categ = entities_node[name]
        if categ then
            for _, entity in ipairs(categ) do
                entities[#entities + 1] = { name, entity }
            end
        end
    end
    -- we assume that ranges don't overlap, so we can sort them
    table_sort(entities, function(a, b)
        return a[2].indices[1] < b[2].indices[1]
    end)
    -- build an array of text segments from the entity ranges
    local buf, pos = {}, 1
    for _, pair in ipairs(entities) do
        local name, entity = unpack(pair)
        local rs, re = unpack(entity.indices)
        local before = unescape(utf8.sub(text, pos, rs))
        buf[#buf + 1] = { text = before, len = utf8.len(before) }
        local field_name, uri_fmt = unpack(entity_categs[name])
        local uri = uri_fmt:format(entity[field_name])
        local display = entity.display_url
        local seglen
        if display then
            seglen = utf8.len(display)
        else
            display = utf8.sub(text, rs + 1, re)
            seglen = re - rs
        end
        buf[#buf + 1] = { text = display, uri = uri, len = seglen }  -- current segment
        pos = re + 1
    end
    -- remaining text
    local tlen = utf8.len(text)
    local remaining = unescape(utf8.sub(text, pos, tlen))
    buf[#buf + 1] = { text = remaining, len = utf8.len(remaining) }
    return setmetatable(buf, segmented_text_mt)
end

return {
    parse = parse_entities,
}
