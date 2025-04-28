---@meta event

local module = {}

---@param timeout number
---@param name? string
---@param ... string
---@return string?, ...
---@overload fun(name?: string, ...: string): string?, ...
function module.pull(timeout, name, ...) end

---@param timeout number
---@param filter? fun(string, ...): boolean
---@return string?, ...
---@overload fun(filter?: fun(string, ...): boolean): string?, ...
function module.pullFiltered(timeout, filter) end

return module