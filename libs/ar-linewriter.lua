local unbundle = _G.require

local intseqs = require('intseqs')
local arTextUtil = require('ar-util')

---@module "unicode"
local unicode = unbundle('unicode')

---@class ar-linewriter.Config
---Accurate mode (each word renders as separate widget)
---In some edge cases this mode kills performance and power consumption
---Useful where words between rows should match their positions
---Default: false
---@field accurateMode? boolean
---Renders unsafe symbols as separate widgets
---In some edge cases this mode kills performance and power consumption
---Useful where words width is play and there are symbols that too wide
---Default: false
---@field safeMode? boolean
---Replaces unsafe symbols with another symbol
---Much better and performant in comparsion with safeMode
---Useful where words width is play and there are symbols that too wide, but fuck this shit
---Default: nil
---@field unsafeReplacement? string
---Text scale (playing with calibration config)
---Default: 1
---@field scale? number
local defaultConfig =
{
    accurateMode = false,
    safeMode = false,
    unsafeReplacement = nil,
    scale = 1,
}

---Writes line using some config
---@param glasses glasses
---@param x integer
---@param y integer
---@param text string
---@param calibration glasses.CalibrationConfig
---@param config? ar-linewriter.Config
---@param fgR? number
---@param fgG? number
---@param fgB? number
---@param fgA? number
---@param bgR? number
---@param bgG? number
---@param bgB? number
---@param bgA? number
---@return fun() dispose
local function linewriter(glasses, x, y, text, calibration, config, fgR, fgG, fgB, fgA, bgR, bgG, bgB, bgA)
    local intseq = intseqs.new()
    local ulen = unicode.len(text)
    config = config or defaultConfig

    local xStep = (config.scale or 1) * calibration.originFontScale * calibration.fontScaleWidthRatio
    local textScale = (config.scale or 1) * calibration.originFontScale

    if config.unsafeReplacement then
        local buffer = {}
        local tmp = ''
        for k = 1, ulen do
            tmp = unicode.sub(text, k, k)
            if not arTextUtil.isCharSafe(tmp) then tmp = config.unsafeReplacement end
            table.insert(buffer, tmp)
        end
        text = table.concat(buffer)
    end

    if bgR then
        local w = glasses.addRect()
        intseqs.add(intseq, w.getID())
        w.setPosition(x, y)
        w.setAlpha(bgA or 1)
        w.setColor(bgR or 0, bgG or 0, bgB or 0)
        w.setSize((config.scale or 1) * calibration.originFontScale * calibration.fontScaleHeightRatio, xStep * ulen)
    end

    if not config.accurateMode and (not config.safeMode or config.unsafeReplacement) then
        local w = glasses.addTextLabel()
        intseqs.add(intseq, w.getID())
        w.setPosition(x, y)
        w.setScale(textScale)
        w.setAlpha(fgA or 1)
        w.setColor(fgR or 0, fgG or 0, fgB or 0)
        w.setText(text)
    else
        ---@type Text2D?
        local lastWidget = nil
        local chars = {}
        local count = 0

        for idx = 1, ulen do
            local c = unicode.sub(text, idx, idx)
            if not arTextUtil.isCharSafe(c) then c = config.unsafeReplacement or c end

            if lastWidget then
                if not arTextUtil.isCharSafe(c) or (c == ' ' and config.accurateMode) then
                    lastWidget.setText(table.concat(chars, nil, 1, count))
                    count = 0
                    lastWidget = nil
                end
            end

            if (c ~= ' ' or not config.accurateMode) then
                if not lastWidget then
                    lastWidget = glasses.addTextLabel()
                    lastWidget.setPosition(x + xStep * (idx - 1), y)
                    lastWidget.setScale(textScale)
                    lastWidget.setAlpha(fgA or 1)
                    lastWidget.setColor(fgR or 0, fgG or 0, fgB or 0)
                    count = 0

                    intseqs.add(intseq, lastWidget.getID())
                end
            end

            if lastWidget then
                count = count + 1
                chars[count] = c
            end
        end
        
        if lastWidget then
            lastWidget.setText(table.concat(chars, nil, 1, count))
            count = 0
            lastWidget = nil
        end
    end

    return function()
        for wId in intseqs.iterNums(intseq) do
            glasses.removeObject(wId)
        end
    end
end

return linewriter