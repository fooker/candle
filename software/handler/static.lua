
return function(driver)
    return {
        start = function(params)
            local r = math.max(0, math.min((params.r or 0) * 255, 255))
            local g = math.max(0, math.min((params.g or 0) * 255, 255))
            local b = math.max(0, math.min((params.b or 0) * 255, 255))

            driver.clear(r, g, b)
            driver.flush()
        end,

        stop = function()
        end,
    }
end

