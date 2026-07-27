local ArBaseWidget2D = require('ar-widgets.BaseWidget2D')

---@class ArVStack2D.ConstructorParams : ArBaseWidget2D.ConstructorParams
---@class ArVStack2D : ArBaseWidget2D
---@field private _ArVStack2D_directionDown boolean
---@field private _ArVStack2D_stack ArBaseWidget2D[]
---@field private _ArVStack2D_step number
---@field new fun(self: ArVStack2D, o: ArVStack2D.ConstructorParams): ArVStack2D
local VStack2D = setmetatable({_ArVStack2D_directionDown=true, _ArVStack2D_step=0}, {__index=ArBaseWidget2D})

function VStack2D:init()
    ArBaseWidget2D.init(self)
    self._ArVStack2D_stack = {}
end

---@param value boolean
function VStack2D:setDirectionDown(value)
    self._ArVStack2D_directionDown = value
    self:requestRedraw()
end
function VStack2D:getDirectionDown() return self._ArVStack2D_directionDown end

---@param widget ArBaseWidget2D
---@param position? integer
function VStack2D:insert(widget, position)
    if not position then position = #self._ArVStack2D_stack + 1 end
    table.insert(self._ArVStack2D_stack, position, widget)
    widget.parent = self
    self:requestRedraw()
end

function VStack2D:addChild(w)
    self:insert(w)
    return true
end

function VStack2D:calculatedSize()
    local step = self._ArVStack2D_step
    local wX, wH = 0, 0
    for w in self:items() do
        local w, h = w:calculatedSize()
        wX = math.max(wX, w)
        wH = wH + h
    end
    wH = wH + step * (#self._ArVStack2D_stack - 1)

    return
        wX,
        wH
end

---@param index integer
function VStack2D:removeIndex(index)
    ---@type ArBaseWidget2D?
    local w = table.remove(self._ArVStack2D_stack, index)
    if w then
        w.parent = nil
        w:requestRedraw()
    end
end

---@param widget ArBaseWidget2D
function VStack2D:removeChild(widget)
    for w, k in self:items() do
        if w == widget then
            self:removeIndex(k)
            return true
        end
    end
    return false
end

---@return fun(): ArBaseWidget2D?, integer?
function VStack2D:items()
    local k = 0
    return function()
        k = k + 1
        local widget = self._ArVStack2D_stack[k]
        if widget then return widget, k end
    end
end

function VStack2D:children()
    return self:items()
end

function VStack2D:redraw()
    local dirDown = self._ArVStack2D_directionDown

    local ch = 0
    local _, mh = self:calculatedSize()

    local step = self._ArVStack2D_step

    if not dirDown then
        ch = mh
    end

    for child in self:children() do
        local _, h = child:calculatedSize()

        local y = dirDown
            and ch
            or ch - h
        ch = ch + (dirDown and (h + step) or -(h + step))
        
        child:setPos(0, y)
    end

    ArBaseWidget2D.redraw(self)
end

return VStack2D