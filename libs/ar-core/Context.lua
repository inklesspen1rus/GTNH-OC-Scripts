local module = {}

---@class ar.Context
---@field glasses glasses
local Context = {}

---@param o {glasses: glasses}
---@return ar.Context
function Context:fromCalibratedGlasses(o)
    setmetatable(o, self)
    self.__index = self
---@diagnostic disable-next-line: return-type-mismatch
    return o
end

return module