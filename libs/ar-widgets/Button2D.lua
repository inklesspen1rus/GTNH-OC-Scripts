local unbundle = _G.require

---@module "event"
local event = unbundle('event')

local WrapBox2D = require('ar-containers.WrapBox2D')

---@class ArButton2D.ConstructorParams : ArWrapBox2D.ConstructorParams
---@class ArButton2D : ArWrapBox2D
---@field private _ArButton2D_eventHandler? any
---@field new fun(self: ArButton2D, o: ArButton2D.ConstructorParams): ArButton2D
local Button2D = setmetatable({}, {__index=WrapBox2D})

function Button2D:redraw()
    self:_installHandler()
    WrapBox2D.redraw(self)
end

---@param x number Widget's local x position
---@param y number Widget's local y position
---@param mode number Click mode
function Button2D:callback(x, y, mode) end

function Button2D:_installHandler()
    if not self._ArButton2D_eventHandler then
        ---@param x number
        ---@param y number
        ---@param mode number
        self._ArButton2D_eventHandler = event.listen('hud_click', function(_, _, _, x, y, mode)
            local mx, my = self:getAbsPos()
            local mw, mh = self:calculatedSize()
            local mx2, my2 = mx + mw, my + mh
            if mx <= x and x < mx2 and my <= y and y < my2 then
                self:callback(x - mx, y - my, mode)
            end
        end)
    end
end

function Button2D:dispose(props)
    if self._ArButton2D_eventHandler then
        event.cancel(self._ArButton2D_eventHandler)
        self._ArButton2D_eventHandler = nil
    end

    WrapBox2D.dispose(self, props)
end

return Button2D