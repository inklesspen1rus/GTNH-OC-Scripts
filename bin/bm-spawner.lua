local robot = require('robot')
local component = require('component')
local inv = component.inventory_controller

local function suckSoul()
    while not inv.suckFromSlot(3, 1, 1) do end
end

local function tick()
    suckSoul()
    robot.turnRight()
    robot.place()
    robot.turnLeft()
    inv.dropIntoSlot(3, 2)
    os.sleep(2)
end

while 1 do
    tick()
end