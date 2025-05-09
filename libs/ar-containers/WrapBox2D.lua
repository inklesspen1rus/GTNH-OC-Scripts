local BaseWidget2D = require('ar-widgets.BaseWidget2D')
local arUtils = require('ar-core.utils')

---@class ArWrapBox2D.ConstructorParams : ArBaseWidget2D.ConstructorParams
---@class ArWrapBox2D : ArBaseWidget2D
---@field new fun(self: ArWrapBox2D, o: ArWrapBox2D.ConstructorParams): ArWrapBox2D
---@field private _ArWrapBox2D_color integer
---@field private _ArWrapBox2D_child? ArBaseWidget2D
---@field private _ArWrapBox2D_padding number
---@field private _ArWrapBox2D_widget? Rect2D
local WrapBox2D = setmetatable({_ArWrapBox2D_padding = 2, _ArWrapBox2D_color=0xFFFFFFFF}, {__index=BaseWidget2D})

---@param color integer
function WrapBox2D:setColor(color)
    self._ArWrapBox2D_color = color
    self:requestRedraw()
end
function WrapBox2D:getColor() return self._ArWrapBox2D_color end

function WrapBox2D:redraw()
    local wid = self._ArWrapBox2D_widget
    if not wid then
        wid = self.context.glasses.addRect()
        self._ArWrapBox2D_widget = wid
        local r, g, b, a = arUtils.colorToRGBA(self._ArWrapBox2D_color)
        wid.setColor(r, g, b)
        wid.setAlpha(a)
    end

    local padding = self._ArWrapBox2D_padding
    local w, h = self:calculatedSize()
    wid.setPosition(self:getAbsPos())
    wid.setSize(h, w)

    BaseWidget2D.redraw(self)
end

function WrapBox2D:calculatedSize()
    local padding = self._ArWrapBox2D_padding

    local child = self._ArWrapBox2D_child
    local childW, childH = 0, 0
    if child then childW, childH = child:calculatedSize() end

    return childW + padding * 2, childH + padding * 2
end

---@param w? ArBaseWidget2D
function WrapBox2D:setChild(w)
    if w == self._ArWrapBox2D_child then return end
    
    local currentChild = self._ArWrapBox2D_child
    if currentChild then
        currentChild.parent = nil
        currentChild:requestRedraw()
    end

    self._ArWrapBox2D_child = w
    if w then
        w:destroyGlasses()
        w:setPos(self._ArWrapBox2D_padding, self._ArWrapBox2D_padding)
        w.parent = self
    end
    self:requestRedraw()
end

function WrapBox2D:children()
    local w = self._ArWrapBox2D_child
    return function()
        local r = w
        w = nil
        return r
    end
end

function WrapBox2D:destroyGlasses()
    local wid = self._ArWrapBox2D_widget
    if wid then
        self.context.glasses.removeObject(wid.getID())
    end

    BaseWidget2D.destroyGlasses(self)
end

return WrapBox2D
