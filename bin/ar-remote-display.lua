local args = table.pack(...)

local textScale = tonumber(args[1]) or .5
local posXScale = tonumber(args[2]) or 2
local posYScale = tonumber(args[3]) or 4
local posX = tonumber(args[4]) or 100
local posY = tonumber(args[5]) or 100
local coloring = (tonumber(args[6]) or 0) == 1

local component = require('component')
local ar = component.glasses
local gpu = component.gpu
local bit = require('bit32')

ar.removeAll()

local w, h = gpu.getResolution()

---@param gpuColor integer
---@return number r
---@return number g
---@return number b
local function gpuColorToRGB(gpuColor)
    local b = bit.band(gpuColor, 0xFF) / 255
    local g = bit.rshift(bit.band(gpuColor, 0xFF00), 8) / 255
    local r = bit.rshift(bit.band(gpuColor, 0xFF0000), 16) / 255
    return r, g, b
end

for y = 1, h do
    ---@type glasses.TextLabel?
    local lastWidget = nil
    local lastFg = 0
    local str = ''

    for x = 1, w do
        local c, fg = gpu.get(x, y)
        if not coloring and fg ~= 0 then fg = 0xFFFFFF end

        if c ~= ' ' then
            if lastWidget then
                if fg ~= lastFg then
                    lastWidget.setText(str)
                    str = ''
                    lastWidget = nil
                end
            end

            if not lastWidget then
                lastWidget = ar.addTextLabel()
                lastWidget.setPosition(posX + (x - 1) * posXScale, posY + (y - 1) * posYScale)
                lastWidget.setScale(textScale)
                lastWidget.setAlpha(1)
                lastWidget.setColor(gpuColorToRGB(fg))
                lastFg = fg
            end
        end
        
        str = str .. c
    end

    if lastWidget then
        lastWidget.setText(str)
    end

    os.sleep(0)
end