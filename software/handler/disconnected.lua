
return function(driver)
    local w = 0 -- The current brightness

    function update()
        driver.clear(w, w, w)
        driver.flush()

        w = (w + 1) % 255
    end

    return {
        start = function(params)
            tmr.alarm(1,              -- Timer ID
                      100,            -- Timer interval
                      tmr.ALARM_AUTO, -- Repeating alarm
                      update)
        end,

        stop = function()
            tmr.stop(1)
        end,
    }
end

