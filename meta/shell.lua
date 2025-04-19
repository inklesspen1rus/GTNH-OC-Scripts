---@meta shell

local module = {}

---@param path string
function module.setWorkingDirectory(path) end

---@param command string
---@param env table<string, string>
---@param ... any
---@return boolean
---@return string? error
function module.execute(command, env, ...) end

return module