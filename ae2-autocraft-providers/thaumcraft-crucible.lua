--- Thaumcraft Crucible Autocraft
---
--- Consumes items and crystallized essense to autocraft via crucible
--- It's cheap and flexible, possible faster than autoalchemy
---
--- Placement rules:
--- You must place robot on a side to crucible
--- Robot must look at crucible in idle
--- Behind robot must be an ME interface
--- On top of ME interface must be chest connected to ME interface
--- Robot must stay on OC charger
--- Robot must have Thaumcraft Wand in tool slot before activation
--- Robot must have empty bucket in last inventory slot
--- Tank with infinite water must be placed to right side of robot
---
--- Robot requirements:
--- Robot must have inventory upgrades (probably, two?)

---@class ItemStack
---@field label string

---@class SidesAPI
---@field bottom 0
---@field top 1
---@field back 2
---@field front 3
---@field right 4
---@field left 5
local sides = require('sides')

---@class ComputerAPI
---@field energy fun(): number
---@field maxEnergy fun(): number
local computer = require('computer')

---@class RobotComponent
---@field move fun(side: number): boolean
---@field turnLeft fun()
---@field turnRight fun()
---@field turnAround fun()
---@field transferTo fun(toSlot: number, amount?: number): boolean
---@field select fun(slot?: number): number
---@field count fun(slot?: number): number
---@field space fun(slot?: number): number
---@field inventorySize fun(): number
---@field drop fun(side: number, count?: number): boolean
---@field suck fun(side: number, count?: number): boolean
---@field use fun(side: number, sneaky?: boolean, duration?: number): boolean, string?
local robot = require('robot')

---@class InventoryControllerComponent
---@field getStackInSlot fun(side: number, slot: number): ItemStack?
---@field getStackInInternalSlot fun(slot?: number): ItemStack?
---@field suckFromSlot fun(side:number, slot:number, count?:number):boolean, string?
---@field dropIntoSlot fun(side:number, slot:number, count?:number):boolean, string?
---@field equip fun(): boolean
local inv = require('component').inventory_controller

---@class State
---@field isDown boolean Is robot placed down
local State =
{
    isDown = true,
    crucibleSide = sides.front,
    hasWater = false,
    bucketSlot = robot.inventorySize(),
    wandSlot = -1,
}

---@param item ItemStack
---@return boolean
local function isItemEssense(item)
    return item.label == 'Crystallized Essense'
end

---@param isDown boolean
local function moveDownState(isDown)
    if State.isDown ~= isDown then
        local result = false
        if isDown then
            result = robot.move(sides.bottom)
        else
            result = robot.move(sides.top)
        end
        if not result then
            error('Unable to move robot down')
        end
    end
end

---Turn robot to side relative to crucible
---I.e. side.front means robot will turn to look at crucible if not yet
---side.back means robot will turn around if robot is looking at crucible currently
---@param side number
local function turnToCrucibleSide(side)
    if State.crucibleSide == side then return end

    local turnMatrix =
    {
        [sides.front * 10 + sides.left] = robot.turnLeft,
        [sides.front * 10 + sides.right] = robot.turnRight,
        [sides.front * 10 + sides.back] = robot.turnAround,

        [sides.left * 10 + sides.back] = robot.turnLeft,
        [sides.left * 10 + sides.front] = robot.turnRight,
        [sides.left * 10 + sides.right] = robot.turnAround,

        [sides.right * 10 + sides.front] = robot.turnLeft,
        [sides.right * 10 + sides.back] = robot.turnRight,
        [sides.right * 10 + sides.left] = robot.turnAround,

        [sides.back * 10 + sides.right] = robot.turnLeft,
        [sides.back * 10 + sides.left] = robot.turnRight,
        [sides.back * 10 + sides.front] = robot.turnAround,
    }

    turnMatrix[State.crucibleSide * 10 + side]()
    State.crucibleSide = side
end

---@async
local function transferToME()
    if robot.count() > 0 then
        moveDownState(true)
        turnToCrucibleSide(sides.back)

        inv.dropIntoSlot(sides.front, 0)
        while robot.count() > 0 do
            ---@diagnostic disable-next-line: undefined-field
            os.sleep(0.25)
            inv.dropIntoSlot(sides.front, 0)
        end
    end
end

---@async
local function equipBucket()
    if State.bucketSlot ~= -1 then
        robot.select(State.wandSlot)
        inv.equip()
        State.wandSlot, State.bucketSlot = State.bucketSlot, State.wandSlot
    end
end

local function isWaterEquiped()
    inv.equip()
    local item = inv.getStackInInternalSlot()
    inv.equip()
    ---@diagnostic disable-next-line: need-check-nil
    return item.label == 'Water Bucket'
end

---@async
local function equipWater()
    equipBucket()

    if not isWaterEquiped() then
        moveDownState(true)
        turnToCrucibleSide(sides.right)
        robot.use(sides.front)
        while not isWaterEquiped() do
            ---@diagnostic disable-next-line: undefined-field
            os.sleep(0.25)
            robot.use(sides.front)
        end
    end
end

---@async
local function refillCrucible()
    equipWater();
    moveDownState(true)
    turnToCrucibleSide(sides.front)
    robot.use(sides.front)

---@diagnostic disable-next-line: undefined-field
    os.sleep(5)
end

---@return integer count Count of slots used
local function suckFromChest()
    moveDownState(false)
    turnToCrucibleSide(sides.back)

    for k = 1, robot.inventorySize() do
        local item = inv.getStackInSlot(sides.front, k)

        if item == nil then
            return k - 1
        end

        robot.select(k)
        if robot.count() > 0 or robot.count(k + 1) > 0 then
            break
        end
        inv.suckFromSlot(sides.front, k)
    end

    error('Insufficient inventory size')
end

---@return integer mainItemSlot Slot contains main item
local function validateInventoryRecipe()
    local mainItemSlot = nil

    for k = 1, robot.inventorySize() do
        robot.select(k)

        local item = inv.getStackInInternalSlot()
        if not item then break end

        if not isItemEssense(item) then
            if not mainItemSlot then
                error('Invalid recipe: several main items found')
            end
            mainItemSlot = k
        end
    end

    if not mainItemSlot then
        error('Invalid recipe: main item not found')
    end

    return mainItemSlot
end

local function swapInternalSlots(slot)
    local slot2 = robot.select()
    if slot2 == slot then return end

    inv.equip()
    robot.select(slot)
    inv.equip()
    robot.select(slot2)
    inv.equip()
end

local function craftRecipe()
    refillCrucible()

    local itemCount = suckFromChest()
    local mainItemSlot = validateInventoryRecipe()

    robot.select(itemCount)
    swapInternalSlots(mainItemSlot)

    moveDownState(false)
    turnToCrucibleSide(sides.front)

    for k = 1, itemCount - 1 do
        robot.select(k)
        robot.drop(sides.front)
    end

---@diagnostic disable-next-line: undefined-field
    os.sleep(0.25)

    robot.select(itemCount)
    robot.drop(sides.front)

---@diagnostic disable-next-line: undefined-field
    os.sleep(0.25)

    robot.select(1)
    robot.suck(sides.front)
end

---@return boolean
local function hasChestRecipe()
    moveDownState(false)
    turnToCrucibleSide(sides.back)

    return inv.getStackInSlot(sides.front, 1) ~= nil
end

local function sitCharge()
    moveDownState(true)
end

local function needToCharge()
    local factor = computer.energy() / computer.maxEnergy()
    return factor < 0.5
end

---@async
local function tick()
    while 1 do

        -- craft
        if hasChestRecipe() then
            craftRecipe()
            transferToME()
        else
            sitCharge()
            -- or sleep
            ---@diagnostic disable-next-line: undefined-field
            os.sleep(0.25)
        end

        -- charge if needed
        while needToCharge() do
            sitCharge()
            ---@diagnostic disable-next-line: undefined-field
            os.sleep(1)
        end
    end
end

while 1 do
    tick()
end
