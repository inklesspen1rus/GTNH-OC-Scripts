---@class ar.Context2D : ar.Context
---@field calibration glasses.CalibrationConfig
local Context2D = {}

---@param o {glasses: glasses, calibration:glasses.CalibrationConfig}
---@return ar.Context2D
function Context2D:fromCalibratedGlasses(o)
    setmetatable(o, self)
    self.__index = self
---@diagnostic disable-next-line: return-type-mismatch
    return o
end

return Context2D