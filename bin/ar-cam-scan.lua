local unbundle = _G.require

local vector = require('vector')
---@module "component"
local component = unbundle('component')
local ar = component.glasses
---@class __203213012931
---@field distance fun(x: number, y: number): number
local cam = component.camera

local r = .5
local startAX = -r
local startAY = -r
local endAX = r
local endAY = r
local step = (endAX - startAX) / 8

local start = vector.new(.5, 2.5, -3)
local dir = vector.new(0,0,-1)

ar.removeAll()

for ax = startAX, endAX, step do
    for ay = startAY, endAY, step do
        local d = cam.distance(ax, ay)

        if d ~= -1 then
            local v = (dir + vector.new(ax, ay, 0)):normalized() * d + start
            local w = ar.addDot3D()
            w.set3DPos(v.x, v.y, v.z)
            w.setColor(1,1,1)
        end
    end
end
