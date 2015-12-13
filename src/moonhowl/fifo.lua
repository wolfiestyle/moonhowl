-- based on https://github.com/daurnimator/fifo.lua
local select = select

local function fifo_new(...)
    local fifo = { ... }
    local head, tail = 1, select("#", ...)

    function fifo.push(val)
        tail = tail + 1
        fifo[tail] = val
    end

    function fifo.pop()
        if head > tail then return nil end
        local val = fifo[head]
        fifo[head] = nil
        head = head + 1
        return val
    end

    function fifo.count()
        return tail - head + 1
    end

    function fifo.empty()
        return head > tail
    end

    local pop = fifo.pop

    -- if `n` specified, get up to `n` items
    function fifo.iter(n)
        if n then
            return function()
                if n > 0 then
                    n = n - 1
                    return pop()
                end
            end, fifo
        else
            return pop, fifo
        end
    end

    return fifo
end

return fifo_new
