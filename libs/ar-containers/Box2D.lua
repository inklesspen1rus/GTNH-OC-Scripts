local BaseWidget2D = require('ar-widgets.BaseWidget2D')
local arUtils = require('ar-core.utils')

---@class ArBox2D.ConstructorParams : ArBaseWidget2D.ConstructorParams

---@class ArBox2D : ArBaseWidget2D
---@field new fun(self: ArBox2D, o: ArBox2D.ConstructorParams): ArBox2D
---@field private _ArBox2D_color integer
---@field private _ArBox2D_widget? Rect2D
---@field private _ArBox2D_w? number
---@field private _ArBox2D_h? number
local Box2D = setmetatable({_ArBox2D_w=0, _ArBox2D_h=0, _ArBox2D_color=0xFFFFFFFF}, {__index=BaseWidget2D})

---@param color integer
function Box2D:setColor(color)
    self._ArBox2D_color = color
    self:requestRedraw()
end
function Box2D:getColor() return self._ArBox2D_color end

function Box2D:redraw()
    local wid = self._ArBox2D_widget
    if not wid then
        wid = self.context.glasses.addRect()
        self._ArBox2D_widget = wid
        local r, g, b, a = arUtils.colorToRGBA(self._ArBox2D_color)
        wid.setColor(r, g, b)
        wid.setAlpha(a)
    end

    wid.setPosition(self:getAbsPos())
    local w, h = self:calculatedSize()
    wid.setSize(h, w)

    BaseWidget2D.redraw(self)
end

function Box2D:calculatedSize()
    return self._ArBox2D_w, self._ArBox2D_h
end

function Box2D:destroyGlasses()
    local w = self._ArBox2D_widget

    if w then
        self.context.glasses.removeObject(w.getID())
    end

    BaseWidget2D.destroyGlasses(self)
end

return Box2D
