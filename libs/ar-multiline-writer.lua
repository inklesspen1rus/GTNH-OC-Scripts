local unbundle = _G.require

local arUtil = require('ar-util')
local linewriter = require('ar-linewriter')

---@param glasses glasses
---@param x number
---@param y number
---@param yInterval number
---@param text string | string[] | fun(): string
---@param calibration glasses.CalibrationConfig
---@param config? ar-linewriter.Config
---@param fgColor? integer
---@param bgColor? integer
---@return fun() dispose
local function write(glasses, x, y, yInterval, text, calibration, config, fgColor, bgColor)
    if type(text) == "string" then
        text = text:gmatch('[^\r\n]+')
    elseif type(text) == "table" then
        local idx = nil
        text = function()
            idx = next(text, idx)
            return text[idx]
        end
    end

    local fg = { nil, nil, nil }

    if fgColor then
        fg = table.pack(arUtil.colorToRGB(fgColor))
    end
    local dises = {}

    ---@type Rect2D?
    local bg = nil
    if bgColor then
        local bgR, bgG, bgB = arUtil.colorToRGB(bgColor)

        local w = glasses.addRect()
        do
            local wId = w.getID()
            table.insert(dises, function()
                glasses.removeObject(wId)
            end)
        end
        w.setPosition(x, y)
        w.setColor(bgR, bgG, bgB)
        w.setAlpha(1)
        bg = w
    end
    
    local allWidth, allHeight = 0, 0

    local xidx = 0
    for line in text do
        local dis = linewriter(glasses, x, y + xidx * (calibration.originFontScale * calibration.fontScaleHeightRatio * ((config or {}).scale or 1) + yInterval), line, calibration, config, table.unpack(fg))
        table.insert(dises, dis)
        xidx = xidx + 1

        if bg then
            local dw, dh = arUtil.calculateTextSize(line, calibration)
            allWidth = math.max(allWidth, dw)
            allHeight = allHeight + dh
        end
    end

    if bg then bg.setSize(allHeight, allWidth) end

    return function()
        for k = #dises,1,-1 do
            dises[k]()
        end
    end
end

return write