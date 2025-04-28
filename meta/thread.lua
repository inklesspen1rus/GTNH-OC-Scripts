---@meta thread
---https://ocdoc.cil.li/api:thread

local module = {}

---@class thread.Thread
local Thread = {}

---@return boolean, string?
function Thread:resume() end

---@return boolean, string?
function Thread:suspend() end

function Thread:kill() end

--- Blocks the caller until t is no longer running or (optionally) returns false if timeout seconds is reached. After a call to t:join() the thread state is “dead”.
---
--- Any of the following circumstances allow join to finish and unblock the caller:
--- + The thread continues running until it returns from its thread function
--- + The thread aborts, or throws an uncaught exception
--- + The thread is suspended
--- + The thread is killed
---
--- Calling thread.waitForAll({t}) is functionally equivalent to calling t:join(). When a processs is closing it will call thread.waitForAll on the group of its child threads if it has any. A child thread blocks its parent thread by the same machanism.
---@param timeout? number
---@return boolean
---@return string? error
function Thread:join(timeout) end

---@return "running" | "suspended" | "dead"
function Thread:status() end

---@param level? number
---@return boolean, string?
function Thread:attach(level) end

---Detaches a thread from its parent if it has one.
---
---Returns nil and an error message if no action was taken,
---otherwise returns self (handy if you want to create and detach a thread in one line).
---A detached thread will continue to run until the computer is shutdown or rebooted, or the thread dies. 
---@return table?, string?
function Thread:detach() end

---@param func fun(...)
---@param ... any
---@return thread.Thread
function module.create(func, ...) end

---@param threads thread.Thread[]
function module.waitForAll(threads) end

---@param threads thread.Thread[]
function module.waitForAny(threads) end

---Returns current Thread. Nothing is returned from this method if called from the init process and not inside any thread. 
---@return thread.Thread?
function module.current() end

return module