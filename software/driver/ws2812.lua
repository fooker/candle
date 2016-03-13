
return function(size)
    -- Inititalize the buffer in the for of [G(u8), R(u8), B(u8), ...]
    local buffer = {}
    for i = 1,size do
        table.insert(buffer, string.char(0, 0, 0))
    end

    -- Define the driver
    return {
        clear = function(r, g, b)
            -- Fill the buffer with the given color
            for i = 1,size do
                buffer[i] = string.char(g, r, b)
            end
        end,

        set = function(i, r, g, b)
            -- Set the given position to the given color
            buffer[i] = string.char(g, r, b)
        end,

        flush = function()
            -- Write the buffer as a single string using GPIO2
            ws2812.write(4, table.concat(buffer))
        end,
    }
end

