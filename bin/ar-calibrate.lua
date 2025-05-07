local unbundle = _G.require

local calibrator = require('ar-calibrator')
local multilineWriter = require('ar-multiline-writer')
local arUtil = require('ar-util')

---@module "serialization"
local ser = unbundle('serialization')

---@module "component"
local component  = unbundle('component')

local ar = component.glasses

local calibration = calibrator.calibrate(ar)
local text = ser.serialize(calibration, true):gsub('=', ' = ')


local w, h = 0, 0
for line in text:gmatch('[^\r\n]+') do
    local dw, dh = arUtil.calculateTextSize(line, calibration)
    w = math.max(w, dw)
    h = h + dh
end

local x, y = arUtil.normToAbsPos(.5, .5, calibration)
x = x - w / 2
y = y - h / 2
local dis = multilineWriter(ar, x, y, 0, text, calibration, {accurateMode=true}, 0, 0xFFFFFF)
os.sleep(5)
dis()

