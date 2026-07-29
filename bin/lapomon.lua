---@class EventLibrary
local event = _G.require 'event'

---@class MinitelLibrary
local net = _G.require 'minitel'

---@class ComponentLibrary
local component = _G.require 'component'

---@class SerializationLibrary
local ser = _G.require 'serialization'

local timerId

function start()
    timerId = event.timer(5, function()
        local _, err = pcall(function()
            local gt = component.gt_machine
            local stored = gt.getStoredEUString()
            local max = gt.getEUCapacityString()

            local s = gt.getSensorInformation()

            local in5s = s[10]
            local out5s = s[11]
            local in5m = s[12]
            local out5m = s[13]
            local in1h = s[14]
            local out1h = s[15]

            net.usend('inkleearth-tun', 994, ser.serialize({
                'datasource.main.supercapacitor',
                {
                    stored=stored,
                    max=max,
                    in5s=in5s,
                    out5s=out5s,
                    in5m=in5m,
                    out5m=out5m,
                    in1h=in1h,
                    out1h=out1h,
                }
            }))
        end)
        _ = err and print(err)
    end, math.huge)
end

function stop()
    _ = timerId and event.cancel(timerId)
    timerId = nil
end