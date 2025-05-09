local BaseWidget = require('ar-widgets.BaseWidget')

---@class ArBaseWidget2D.ConstructorParams: ArBaseWidget.ConstructorParams
---@field context ar.Context2D

---@class ArBaseWidget2D: ArBaseWidget
---@field context ar.Context2D
---@field protected parent ArBaseWidget2D
---@field private _ArBaseWidget2D_x integer
---@field private _ArBaseWidget2D_y integer
---@field new fun(self, o: ArBaseWidget2D.ConstructorParams)
---@field children fun(self): fun(): ArBaseWidget2D?
local BaseWidget2D = setmetatable({_ArBaseWidget2D_x=0, _ArBaseWidget2D_y=0}, {__index=BaseWidget})

---@return integer w
---@return integer h
function BaseWidget2D:calculatedSize() return 0, 0 end

---@param x number
---@param y number
function BaseWidget2D:setPos(x, y)
    if self._ArBaseWidget2D_x == x and self._ArBaseWidget2D_y == y then return end
    self._ArBaseWidget2D_x, self._ArBaseWidget2D_y = x, y
    self:requestRedraw()
end
function BaseWidget2D:getPos() return self._ArBaseWidget2D_x, self._ArBaseWidget2D_y end

---@return number maxWidth
---@return number maxHeight
function BaseWidget2D:sizeLimit()
    if self.parent then
        return self.parent:sizeLimit()
    end

    return
        self.context.calibration.screenWidth,
        self.context.calibration.screenWidth
end

function BaseWidget2D:getAbsPos()
    local x, y = self:getPos()
    if self.parent then
        local px, py = self.parent:getAbsPos()
        x = x + px
        y = y + py
    end
    return x, y
end

return BaseWidget2D