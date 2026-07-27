local BaseWidget = require('ar-widgets.BaseWidget2D')

---@class ArRoot2D.ConstructorParams : ArBaseWidget2D.ConstructorParams
---@class ArRoot2D : ArBaseWidget2D
---@field new fun(self: ArRoot2D, o: ArRoot2D.ConstructorParams): ArRoot2D
---@field private _ArRoot2D_children? table<ArBaseWidget2D, number>
local Root2D = setmetatable({}, {__index=BaseWidget})

function Root2D:addChild(w)
    if not self._ArRoot2D_children then self._ArRoot2D_children = {} end
    if self._ArRoot2D_children[w] then return false end
    self._ArRoot2D_children[w] = 0
    w.parent = self
    w:requestRedraw()
    return true
end

function Root2D:removeChild(w)
    if not self._ArRoot2D_children then self._ArRoot2D_children = {} end
    if self._ArRoot2D_children[w] then
        self._ArRoot2D_children[w] = nil
        w.parent = nil
        w:requestRedraw()
        return true
    end
    return false
end

function Root2D:children()
    return pairs(self._ArRoot2D_children)
end

return Root2D
