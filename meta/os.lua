---@meta _

---@param time number Seconds to sleep
os.sleep = function(time) end

---@param env string
---@return string
---@overload fun(): table<string, string>
os.getenv = function(env) end

---@param command string
---@return boolean success
os.execute = function(command) end

return os