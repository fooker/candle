
--
-- Global configuration
--
WIFI_SSID = ''
WIFI_PASS = ''

MQTT_HOST = '10.0.23.127'
MQTT_PORT = 1883
MQTT_PATH = 'candle'
MQTT_USER = 'candle'
MQTT_PASS = ''

DRIVER_NAME = 'ws2812'
DRIVER_SIZE = 71


-- Initialize WiFi in 'client' mode and configure it with the provided
-- credentials
wifi.setmode(wifi.STATION)
wifi.sta.config(WIFI_SSID, WIFI_PASS)
wifi.sta.autoconnect(1)


-- Load the driver
driver = require('driver/' .. DRIVER_NAME)(DRIVER_SIZE)


-- Start a handler signaling the connecting state
handler = require('handler/disconnected')(driver)
handler.start(nil)


-- Initialize the MQTT client and let it send a testament if it goes down
-- marking the node as offline
m = mqtt.Client('candle-' .. node.chipid(),
                120, -- TTL
                MQTT_USER,
                MQTT_PASS)

m:lwt(MQTT_PATH .. '/' .. node.chipid() .. '/status',
      cjson.encode({ status = 'offline', }),
      0, -- QoS level
      1) -- Retain flag

m:on('connect', function(client)
    -- Subscribe to nodes configuration topic
    client:subscribe(MQTT_PATH .. '/' .. node.chipid() .. '/config',
                     0) -- QoS level

    -- Start timer publishing node status and details
    tmr.alarm(6, 5000, tmr.ALARM_AUTO, function()
        local mac = wifi.sta.getmac()
        local ip = wifi.sta.getip()
        local _, _, _, bssid = wifi.sta.getconfig()

        client:publish(MQTT_PATH .. '/' .. node.chipid() .. '/status',
                       cjson.encode({ status = 'online',
                                      net = { mac = mac,
                                              ip = ip,
                                              bssid = bssid, },
                                      driver = { name = DRIVER_NAME,
                                                 size = DRIVER_SIZE, }}),
                       0, -- Qos level
                       0) -- Retain flag
    end)
end)

m:on('offline', function(client)
    -- Stop timer publishing node details
    tmr.stop(6)
end)

m:on('message', function(client, topic, data)
    -- Only handle confiuration changes for this node
    if topic == MQTT_PATH .. '/' .. node.chipid() .. '/config' then
        local config = cjson.decode(data)

        -- Stop current handler - if any
        if handler ~= nil then
            handler.stop()
        end

        -- Load and start new handler
        loader = require('handler/' .. config.mode)
        if loader ~= nil then
            handler = loader(driver)
            handler.start(config.params)
        else
            handler = nil
        end
    end
end)


-- Wait for WiFi connection to establish and connect to MQTT if so
wifi.sta.eventMonReg(wifi.STA_GOTIP, function()
    -- Connect to MQTT server
    m:connect(MQTT_HOST,
              MQTT_PORT,
              0, -- TLS flag
              1) -- Auto-reconnect flag
end)
wifi.sta.eventMonStart()

