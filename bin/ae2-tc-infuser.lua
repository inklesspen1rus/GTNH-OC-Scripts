--- AE2 Thaumcraft Infuser helper robot
---
--- Block placement
--- am
--- ac
--- ai
--- aa
--- rp
--- 
--- Where:
---     a - Air
---     m - ME Interface
---     c - Crawler
---     i - Infuser
---     p - Pedestal
---     r - Robot running this program


local component = require('component')
local robot     = require('robot')
local inv = component.inventory_controller
local sides = require('sides')
local ser       = require('serialization')

---@type thread
local currentWorker = nil

local function isItemStacksEqual(itemStack1, itemStack2)
    return ser.serialize(itemStack1) == ser.serialize(itemStack2)
end

local function createWaitWorker(currentItemStack, returnWorker)
    return coroutine.create(function()
        while 1 do
            local itemStack = inv.getStackInSlot(sides.front, 1)

            if isItemStacksEqual(itemStack, currentItemStack) then
                inv.suckFromSlot(sides.front, 1)

                while not robot.up() do end
                while not robot.up() do end
                while not robot.up() do end
                while not robot.up() do end

                while not inv.dropIntoSlot(sides.front, 1) do end

                while not robot.down() do end
                while not robot.down() do end
                while not robot.down() do end
                while not robot.down() do end

                currentWorker = returnWorker
                return
            end

            coroutine.yield()
        end
    end)
end

local function idleWorker()
    while 1 do
        local itemStack = inv.getStackInSlot(sides.front, 1)
        if itemStack then
            currentWorker = createWaitWorker(itemStack, currentWorker)
        end
        coroutine.yield()
    end
end

local function tick()
    coroutine.resume(currentWorker)
end

currentWorker = coroutine.create(idleWorker)

while 1 do
    tick()
    os.sleep(0.5)
end