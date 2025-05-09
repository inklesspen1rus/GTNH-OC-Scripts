local unbundle = _G.require
local WrapBox2D= require "ar-containers.WrapBox2D"

---@module "computer"
local computer = unbundle('computer')

---@module "component"
local component = unbundle('component')

---@module "event"
local event = unbundle('event')

local Button2D = require('ar-widgets.Button2D')
local Text2D = require('ar-widgets.Text2D')
local Context2D = require('ar-core.Context2D')

local context = Context2D:fromCalibratedGlasses({
    glasses = component.glasses,
    calibration = {
        originFontScale = .5,
        screenWidth = 480,
        screenHeight = 270,
        fontScaleWidthRatio = 4,
        fontScaleHeightRatio = 8,
    },
})

local button = Button2D:new({ context = context })
local text = Text2D:new({ context = context })
local border = WrapBox2D:new({ context = context })

text:setScale(2) text:setText("Reboot") text:setColor(0xFF0000FF)
button:setChild(text) button:setColor(0xFFFFFFFF)
border:setChild(button) border:setColor(0xFF0000FF) border:setPos(80, 10)

function button:callback(x, y, mode)
    if mode ~= 0 then text:setText("Press LBM!") return end
    border:dispose()
    computer.shutdown(true)
end

event.pull('interrupted')
border:dispose()