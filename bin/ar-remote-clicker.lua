local posX = 160
local posY = 0

local component = require('component')
local computer  = require('computer')
local gpu = component.gpu

local resolutionW, resolutionH = gpu.getResolution()
local fontScale = 0.5
local fontWidthFactor = 4
local fontHeightFactor = 4
local posEndX = posX + resolutionW * fontScale * fontWidthFactor
local posEndY = posY + resolutionH * fontScale * fontHeightFactor
local hudScreenW = posEndX - posX + 1
local hudScreenH = posEndY - posY + 1

local isMineOS = not os.sleep

---@type fun(time: number)
local sleep = os.sleep or require('Event').sleep

local function installEventHandler(event_name, fun)
    if not isMineOS then
        local event = require('event')
        event.listen(event_name, fun)
    else
        -- local event = require('Event')
        print('MineOS currently not supported')
    end
end

installEventHandler('hud_keyboard', function(...)
    ---@type any, any, string, integer, integer, integer
    local _, _, nickname, a, b = ...

    computer.pushSignal('key_down', component.keyboard.address, a, b, nickname)
    computer.pushSignal('key_up', component.keyboard.address, a, b, nickname)
end)

installEventHandler('hud_click', function(...)
    ---@type any, any, string, integer, integer, integer
    local _, _, nickname, x, y, mode = ...

    -- Convert hud's coords to computer's coords
    if x < posX or x > posEndX then return end
    if y < posY or y > posEndY then return end

    x = (x - posX) / hudScreenW
    y = (y - posY) / hudScreenH

    if mode >= 2 then return end

    computer.pushSignal('touch', component.screen.address, x, y, mode, nickname)
    computer.pushSignal('drop', component.screen.address, x, y, mode, nickname)
end)