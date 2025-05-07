local unbundle = _G.require

---@module "unicode"
local unicode = unbundle('unicode')

---@module "bit32"
local bit = unbundle('bit32')

local unicode_upper = unicode.upper
local unicode_lower = unicode.lower
local string_len = string.len

local function isCharBraille(chr)
    local a, b, c = string.byte(chr, 1, 3)
    return c and a == 226 and (b >= 160 and b <= 163)
end

---@param c string
---@return boolean
local function isByteCharSafe(c)
    return true
end

---@param c string
---@return boolean
local function isCharSafe(c)
    if string_len(c) > 1 then
        return isCharBraille(c) or unicode_upper(c) ~= unicode_lower(c)
    else
        return isByteCharSafe(c)
    end
end

---Plays with utf8 characters
---@param string string
---@param charPos integer
---@param charEnd integer
local function isStringCharSafe(string, charPos, charEnd)
    return isCharSafe(string.sub(string, charPos, charEnd))
end

---@param gpuColor integer
---@return number r
---@return number g
---@return number b
local function colorToRGB(gpuColor)
    local b = bit.band(gpuColor, 0xFF) / 255
    local g = bit.rshift(bit.band(gpuColor, 0xFF00), 8) / 255
    local r = bit.rshift(bit.band(gpuColor, 0xFF0000), 16) / 255
    return r, g, b
end


local function RGBToColor(r, g, b)
    local x = 0
    x = x + math.floor(b * 255)
    x = x + bit.lshift(math.floor(g * 255), 8)
    x = x + bit.lshift(math.floor(r * 255), 16)
    return x
end

---@param calibration glasses.CalibrationConfig
---@param scale number
---@return number finalScale
local function calculateTextFinalScale(calibration, scale)
    return calibration.originFontScale * scale
end

---@param text string
---@param calibration glasses.CalibrationConfig
---@param scale? number
---@return number
---@return number
local function calculateTextSize(text, calibration, scale)
    return unicode.len(text) * calibration.fontScaleWidthRatio * (scale or 1), calibration.fontScaleHeightRatio * (scale or 1)
end

---@param x number
---@param y number
---@param calibration glasses.CalibrationConfig
---@return number absX
---@return number absY
local function normToAbsPos(x, y, calibration)
    return calibration.screenWidth * x, calibration.screenHeight * y
end

return {
    isCharBraille = isCharBraille,
    isCharSafe = isCharSafe,
    isByteCharSafe = isByteCharSafe,
    isStringCharSafe = isStringCharSafe,
    colorToRGB = colorToRGB,
    RGBToColor = RGBToColor,
    calculateTextFinalScale = calculateTextFinalScale,
    normToAbsPos = normToAbsPos,
    calculateTextSize = calculateTextSize,
}