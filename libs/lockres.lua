--- OpenOS Library to guarantee exclusive access to shared resources
--- Works if even inlined into other programs

local internalApiLocalVersion = 0
---@diagnostic disable-next-line: undefined-field
local firstInit = not _G._AaA_lockres_internalApi

---@diagnostic disable-next-line: undefined-field
local internalApi = _G._AaA_lockres_internalApi or {
    ---@type table<any, any>
    _locks = {},

    _nilident = {},

    _version = internalApiLocalVersion,
}

-- Stable internal API
if firstInit then
    function internalApi:tryRunInLock(lock, func)
        -- Nil can't be a table key. So we use singleton.
        if lock == nil then
            lock = self._nilident
        end

        if self._locks[lock] and #self._locks[lock] > 0 then
            return false
        end

        self._locks[lock] = 0
        local ret = table.pack(pcall(func))
        self._locks[lock] = nil

        if not ret[1] then
            error(ret[2])
        end

        return true, select(2, ret)
    end

    _G._AaA_lockres_internalApi = internalApi
else
    -- We need upgrade, but it need to develop
    -- So we're not upgrading and just crying
    if internalApi._version < internalApiLocalVersion then
        warn("lockres.lua: Version of shared state is lower than local. This can lead bugs!")
    end
end

local module = {}

--- Inplace execution with blocking call.
--- The most easest but unsafe API
--- Runs function inplace.
--- If there are lock already, waits with os.sleep and retries
---
---@generic R
---@param lock any
---@param func fun(): R
---@return boolean, R?
function module.tryRunIn(lock, func)
    return internalApi:tryRunInLock(lock, func)
end

--- Run later (based on event library from OpenOS)
---
---@generic R
---@param lock any
---@param func fun()
---@param after? fun() Callback to call after execution and lock freeing
---@return fun() dispose Function to cancel callback
function module.runOn(lock, func, after)
    local unbundle = _G.require
    ---@module "event"
    local event = unbundle('event')

    -- We assumes that locks are short-timed
    -- Probably, not?
    -- Anyway, we're trying every tick
    -- TODO: Grow timer interval if we can't execute for a long time
    local state = { handler = nil, failCount = 0, interval = 0.05, timerId = nil }
    state.handler = function()
        local success = module.tryRunWith(lock, func)
        if success then
            event.cancel(state.timerId)
            if after then after() end
            return
        end

        -- If we can't take lock for a while, increase interval if we can
        if state.failCount > 10 and state.interval < 0.25 then
            state.interval = state.interval + .05
            event.cancel(state.timerId)
            state.timerId = event.timer(0.05, state.handler, math.huge)
            state.failCount = 0
            return
        end

        state.failCount = state.failCount + 1
    end

    state.timerId = event.timer(0.05, state.handler, math.huge)
    
    return function ()
        event.cancel(state.timerId)
    end
end

--- Run function with lock
--- The most easest but blocking API
--- If there are lock already, waits with os.sleep and retries
---
---@generic R
---@param lock any
---@param func fun(): R
---@param waiter? fun()
---@return R
function module.runIn(lock, func, waiter)
    -- Task's state
    local state = { done = false, ret = nil }

    -- Enqueue task
    module.runOn(lock, function()
        state.ret = table.pack(func())
        state.done = true
    end)

    -- Wait for task completion
    if not waiter then waiter = function() os.sleep(0.1) end end
    while not state.done do waiter() end

    -- Return result
---@diagnostic disable-next-line: redundant-return-value
    return table.unpack(state.ret)
end

return module