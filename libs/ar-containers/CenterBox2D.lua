local unbundle = _G.require

local Box2D = require('ar-containers.Box2D')

---@class ArCenterBox2D.ConstructorParams : ArBox2D.ConstructorParams

---@class ArCenterBox2D : ArBox2D
---@field new fun(self: ArCenterBox2D, o: ArCenterBox2D.ConstructorParams): ArCenterBox2D
---@field private _ArCenterBox2D_child? ArBaseWidget2D
---@field private _ArCenterBox2D_color integer
---@field private _ArCenterBox2D_padding integer
local CenterBox2D = setmetatable({_ArCenterBox2D_padding=0, _ArCenterBox2D_color=0xFFFFFFFF}, {__index=Box2D})

---@param color integer
function CenterBox2D:setColor(color)
    self._ArCenterBox2D_color = color
    self:requestRedraw()
end
function CenterBox2D:getColor() return self._ArCenterBox2D_color end

function CenterBox2D:redraw()
    local child = self._ArCenterBox2D_child
    if child then
        local mw, mh = self:calculatedSize()
        local cw, ch = child:calculatedSize()
        child:setPos(mw / 2 - cw / 2, mh / 2 - ch / 2)
        child:redraw()
    end

    Box2D.redraw(self)
end

function CenterBox2D:calculatedSize()
    return 
end

---@param w? ArBaseWidget2D
function CenterBox2D:setChild(w)
    if w == self._ArCenterBox2D_child then return end
    
    local currentChild = self._ArCenterBox2D_child
    self._ArCenterBox2D_child = w
    if currentChild then
        currentChild.parent = nil
        currentChild:requestRedraw()
    end

    if w then
        w.parent = self
    end
    
    self:requestRedraw()
end

function CenterBox2D:children()
    local child = self._ArCenterBox2D_child
    return function()
        local c = child
        child = nil
        return c
    end
end

return CenterBox2D
