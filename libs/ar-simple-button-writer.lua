---@class glasses.SimpleButtonWriter.Config
---@field color number
---@field textScale? number
---@field borderColor? number
local defaultConfig =
{
    textScale = 1
}

---@class glasses.SimpleButtonWriter
local SimpleButtonWriter = {}

---@param calibration any
---@param config any
function SimpleButtonWriter.calculateMinSize(text, calibration, config)
    
end

return SimpleButtonWriter