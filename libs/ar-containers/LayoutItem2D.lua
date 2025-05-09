local BaseWidget2D = require('ar-widgets.BaseWidget2D')

---@class ArLayoutItem2D.ConstructorParams : ArBaseWidget2D.ConstructorParams
---@class ArLayoutItem2D : ArBaseWidget2D
---@field private _ArLayoutItem2D_minW integer
---@field private _ArLayoutItem2D_maxW integer
---@field private _ArLayoutItem2D_minH integer
---@field private _ArLayoutItem2D_maxH integer
---@field private _ArLayoutItem2D_child? ArBaseWidget2D
---@field new fun(self: ArLayoutItem2D, o: ArLayoutItem2D.ConstructorParams): ArLayoutItem2D
local LayoutItem2D = setmetatable({
    _ArLayoutItem2D_minW = 0,
    _ArLayoutItem2D_maxW = math.huge,
    _ArLayoutItem2D_minH = 0,
    _ArLayoutItem2D_maxH = math.huge,
    _ArLayoutItem2D_color = 0xFFFFFFFF,
}, {__index=BaseWidget2D})

function LayoutItem2D:calculatedSize()
    local child = self._ArLayoutItem2D_child
    return child
        and child:calculatedSize()
        or self._ArLayoutItem2D_minW, self._ArLayoutItem2D_minH
end

function LayoutItem2D:sizeLimit()
    local w, h = BaseWidget2D.sizeLimit(self)
    w = math.min(w, self._ArLayoutItem2D_maxW)
    h = math.min(h, self._ArLayoutItem2D_maxH)
    return w, h
end

---@param w ArBaseWidget2D?
function LayoutItem2D:setChild(w)
    local child = self._ArLayoutItem2D_child
    if child == w then return end

    self._ArLayoutItem2D_child = w

    if child then
        child.parent = nil
        child:requestRedraw()
    end

    if w then
        w.parent = nil
        w:setPos(0, 0)
    end
    self:requestRedraw()
end

function LayoutItem2D:children()
    local child = self._ArLayoutItem2D_child
    return function()
        local c = child
        child = nil
        return c
    end
end

return LayoutItem2D
