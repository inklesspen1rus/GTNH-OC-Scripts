local unbundle = _G.require

---@module "event"
local event = unbundle('event')

---@class ArBaseWidget
---@field context ar.Context
---@field protected parent? ArBaseWidget
---@field private redrawRequested boolean
---@field disposed boolean
local BaseWidget = {disposed=false}

---@class ArBaseWidget.ConstructorParams
---@field context ar.Context
---@param o ArBaseWidget.ConstructorParams
---@return ArBaseWidget
function BaseWidget:new(o)
    setmetatable(o, self)
    self.__index = self
    ---@cast o any
    o:init()
    return o
end

function BaseWidget:init()
    self:requestRedraw()
end

function BaseWidget:redraw()
    for w in self:children() do
        w:redraw()
    end
end

function BaseWidget:destroyGlasses()
    for w in self:children() do
        w:destroyGlasses()
    end
end

---@return fun(): ArBaseWidget?
function BaseWidget:children() return function() end end

---@protected
function BaseWidget:requestRedraw()
    if not self.disposed then
        if self.parent then
            self.parent:requestRedraw()
        elseif not self.redrawRequested then
            self.redrawRequested = true
            event.timer(0.0, function ()
                if not self.disposed and not self.parent then
                    self:redraw()
                end
                self.redrawRequested = false
            end, 1)
        end
    end
end

---@param props? table
function BaseWidget:dispose(props)
    if not props or not props.dontClearGlasses then
        self:destroyGlasses()
    end

    for w in self:children() do
        w:dispose(props)
    end

    self.disposed = true
end

return BaseWidget