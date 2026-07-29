---@meta minitel

---@class MinitelLibrary
local module = {}

--- Sends an unreliable packet to host on port containing data, optionally with the packet ID pid.
---@param host string
---@param port number
---@param data string
---@param pid string?
function module.usend(host, port, data, pid) end

--- Sends a reliable packet to host on port containing data. If block is true, don't wait for a reply.
---@param host string
---@param port number
---@param data string
---@param block boolean
function module.rsend(host, port, data, block) end

--- Sends data reliably and in order to host on port.
---@param host string
---@param port number
---@param data string
function module.send(host, port, data) end

return module