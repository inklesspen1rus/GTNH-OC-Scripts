--- Placement rules:
--- 1 layer 0 layer
--- XXX     XCX
--- XRX     XJX
--- XHM     XXX
--- 
--- X - Empty
--- C - Cauldron
--- R - robot
--- J - OC Charger
--- H - Chest
--- M - ME interface

local inv = require('component').inventory_controller
local robot = require('robot')
local computer = require('computer')
local sides = require('sides')

local function hasChestRecipe()
    local item = inv.getStackInSlot(sides.front, 1)
    return not not item
end

---@async
local function craft()
    local k = 1
    while 1 do
        if inv.suckFromSlot(sides.front, k) then
            robot.turnAround()
            robot.drop()
            robot.turnAround()
            os.sleep(0.5)
            k = k + 1
        else
            local n = 0
            robot.turnAround()
            while not robot.suck() do
                os.sleep(1)
                n = n + 1
                if n == 10 then error('Unable to craft') end
            end
            robot.turnAround()
            break
        end
    end
end

---@async
local function saveToME()
    robot.turnLeft()
    robot.forward()
    robot.turnRight()
    while not inv.dropIntoSlot(sides.front, 1) do
        os.sleep(1)
    end
    robot.turnRight()
    robot.forward()
    robot.turnLeft()
end

local function needToCharge()
    local factor = computer.energy() / computer.maxEnergy()
    return factor < 0.5
end

---@async
local function tick()
    while 1 do
        if hasChestRecipe() then
            craft()
            saveToME()
        else
            os.sleep(1)
        end

        while needToCharge() do os.sleep(1) end
    end
end

local function setup()
    robot.select(1)
end

setup()

while 1 do
    local succ, err = pcall(tick)
    if not succ then
        local f = io.open('error', 'w')
        if f then
            f:write(err)
            f:close()
        end
        print(err)
        break
    end
end