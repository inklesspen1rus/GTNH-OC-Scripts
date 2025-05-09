local unbundle = _G.require
local event    = unbundle("event")

local Context2D = require('ar-core.Context2D')
local UpdatingText2D = require('ar-widgets.UpdatingText2D')
local WrapBox2D = require('ar-containers.WrapBox2D')

---@module "component"
local component = unbundle('component')

local tps = component.tps_card
local glasses = component.glasses

glasses.removeAll()

local context = Context2D:fromCalibratedGlasses({
    glasses = glasses,
    calibration = {
        originFontScale = .5,
        screenWidth = 480,
        screenHeight = 270,
        fontScaleWidthRatio = 4,
        fontScaleHeightRatio = 8,
    },
})

local w = UpdatingText2D:new({
    context = context
})
local box = WrapBox2D:new({
    context = context
})

---@param wid ArText2D
local function updateWidger(wid)
    local tt = tps.getOverallTickTime()
    local tp = tps.convertTickTimeIntoTps(tt)

    wid:setText(string.format('TPS: %.1f (%.1f ms)', tp, tt))
end

w:setTimer(updateWidger, .25)
updateWidger(w)
w:setScale(context.calibration.screenHeight / context.calibration.fontScaleHeightRatio / 10)
box:setChild(w)

local box2 = WrapBox2D:new({context = context})
box2:setPos(80, 10)
box2:setChild(box)
box2:setColor(0xFF000000)

event.pull('interrupted')

box2:dispose()
