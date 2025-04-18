local robot = require('robot')
local sides = require('sides')
local inv = require('component').inventory_controller

local args = table.pack(...)

local width = tonumber(args[1] or 23)
local layers = tonumber(args[2] or (1 * 3)) -- 6 height
local mid = math.floor((width + 1) / 2)

if width % 2 == 0 then
    error('Width must be odd')
end

-- Crop Manager has height radius 3
-- 1 Plant
-- 2 Dirt
-- 3 Plant
-- 2 Dirt
-- 1 Plant
-- 0 Dirt

local function placeDirtRow()
    for _ = 1, width do robot.forward() end

    for _ = 1, width do
        robot.back()
        robot.place()
    end
end

---@param holeSize? integer Hole radius in the center
local function placeCropRow(holeSize)
    holeSize = holeSize or 0
    local holeRadius = math.floor((holeSize + 1) / 2)

    local holeStart = mid - holeRadius
    local holeEnd = mid + holeRadius

    if holeRadius == 0 then
        holeEnd = width + width
        holeStart = holeEnd
    end

    robot.up()
    for xx = 1, width do robot.forward() end

    for k = 1, width do
        if k < holeStart or k >= holeEnd then
            robot.placeDown()
            inv.equip()
            robot.use(sides.bottom)
            inv.equip()
        end
        robot.back()
    end
    robot.down()
end

---@param layer integer
---@param row integer
---@param func fun()
local function execAtRow(layer, row, func)
    robot.turnRight()
    for xx = 2, row do
        robot.forward()
    end
    robot.turnLeft()

    for xx = 2, layer do
        robot.up()
        robot.up()
    end
    
    func()

    for xx = 2, layer do
        robot.down()
        robot.down()
    end

    robot.turnLeft()
    for xx = 2, row do
        robot.forward()
    end
    robot.turnRight()
end

local function loadDirt()
    robot.turnAround()
    inv.dropIntoSlot(3, 1)
    inv.suckFromSlot(3, 2)
    robot.turnAround()
end

local function loadCropsAndSeeds()
    robot.turnAround()

    robot.up()
    inv.dropIntoSlot(3, 1)
    inv.suckFromSlot(3, 2)

    robot.up()
    inv.equip()
    inv.dropIntoSlot(3, 1)
    inv.suckFromSlot(3, 2)
    inv.equip()

    robot.down()
    robot.down()

    robot.turnAround()
end

local function unloadDirt()
    robot.turnAround()
    inv.dropIntoSlot(3, 1)
    robot.turnAround()
end

local function unloadCropsAndSeeds()
    robot.turnAround()

    robot.up()
    inv.dropIntoSlot(3, 1)

    robot.up()
    inv.equip()
    inv.dropIntoSlot(3, 1)
    inv.equip()

    robot.down()
    robot.down()

    robot.turnAround()
end

for layer = 1,layers do
    for row = 1,width do
        loadDirt()
        execAtRow(layer, row, function()
            placeDirtRow()
        end)
        unloadDirt()

        loadCropsAndSeeds()
        execAtRow(layer, row, function()
            if row + 1 == mid or row - 1 == mid then
                placeCropRow(1)
            elseif row == mid then
                placeCropRow(3)
            else
                placeCropRow()
            end
        end)
        unloadCropsAndSeeds()
    end
end