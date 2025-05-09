local unbundle = _G.require

---@module "event"
local event = unbundle('event')
local Text2D = require('ar-widgets.Text2D')

---@class ArUpdatingText2D: ArText2D
---@field private _ArUpdatingText2D_timer? any
---@field new fun(self, o: ArText2D.ConstructorParams): ArUpdatingText2D
local UpdatingText2D = setmetatable({}, {__index=Text2D})

---@param func? fun(w: ArUpdatingText2D)
---@param interval? number
function UpdatingText2D:setTimer(func, interval)
    local timer = self._ArUpdatingText2D_timer
    if timer then
        event.cancel(timer)
        timer = nil
    end

    if func and interval then
        local newTimer = event.timer(interval, function()
            if not self.disposed then
                func(self)
            end
        end, math.huge)
        timer = newTimer
    end

    self._ArUpdatingText2D_timer = timer
end

function UpdatingText2D:dispose(props)
    local timer = self._ArUpdatingText2D_timer
    self._ArUpdatingText2D_timer = nil
    if timer then
        event.cancel(timer)
    end

    Text2D.dispose(self, props)
end

return UpdatingText2D
