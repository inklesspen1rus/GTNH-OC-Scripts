local unbundle = _G.require

local BaseWidget2D = require('ar-widgets.BaseWidget2D')
local arUtils = require('ar-core.utils')

---@module "unicode"
local unicode = unbundle('unicode')

---@class ArText2D.ConstructorParams : ArBaseWidget2D.ConstructorParams

---@class ArText2D : ArBaseWidget2D
---@field private _ArText2D_widget? Text2D
---@field private _ArText2D_color integer
---@field private _ArText2D_text string
---@field private _ArText2D_scale number
---@field new fun(self: ArText2D, o: ArText2D.ConstructorParams): ArText2D
local Text2D = setmetatable({_ArText2D_x=0, _ArText2D_y=0, _ArText2D_color=0, _ArText2D_text='', _ArText2D_scale=1}, {__index=BaseWidget2D})

function Text2D:redraw()
    local w = self._ArText2D_widget
    if not w then
        w = self.context.glasses.addTextLabel()
        self._ArText2D_widget = w
    end

    local calibration = self.context.calibration
    local originFontScale = calibration.originFontScale;

    local r, g, b, a = arUtils.colorToRGBA(self._ArText2D_color)
    w.setColor(r, g, b)
    w.setAlpha(a)
    w.setText(self._ArText2D_text)
    w.setScale(originFontScale * self._ArText2D_scale)
    local ww, hh = self:getAbsPos()
    w.setPosition(ww, hh)

    BaseWidget2D.redraw(self)
end

function Text2D:calculatedSize()
    local calibration = self.context.calibration
    local fontScale = calibration.originFontScale * self._ArText2D_scale
    local maxW = self:sizeLimit()

    local maxLen = math.floor(maxW / fontScale * calibration.fontScaleHeightRatio)

    return
        fontScale * calibration.fontScaleWidthRatio * math.min(maxLen, unicode.len(self._ArText2D_text)),
        fontScale * calibration.fontScaleHeightRatio
end

---@param text string
function Text2D:setText(text)
    if text == self._ArText2D_text then return end
    self._ArText2D_text = text
    self:requestRedraw()
end
function Text2D:getText() return self._ArText2D_text end

---@param scale number
function Text2D:setScale(scale)
    if scale == self._ArText2D_scale then return end
    self._ArText2D_scale = scale
    self:requestRedraw()
end
function Text2D:getScale() return self._ArText2D_scale end

---@param color number
function Text2D:setColor(color)
    if color == self._ArText2D_color then return end
    self._ArText2D_color = color
    self:requestRedraw()
end
function Text2D:getColor() return self._ArText2D_color end

function Text2D:destroyGlasses()
    local w = self._ArText2D_widget
    if w then
        self.context.glasses.removeObject(w.getID())
    end
    self._ArText2D_widget = nil

    BaseWidget2D.destroyGlasses(self)
end

return Text2D