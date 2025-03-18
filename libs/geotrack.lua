---@meta geotrack

local fs = require('filesystem')
local ser = require('serialization')
local hasRobot, robot = pcall(require, 'robot')

fs.makeDirectory('/var')
fs.makeDirectory('/var/lib')
fs.makeDirectory('/var/lib/geotrack')

local module = {}

---@type [integer, integer, integer][]
local rotToVecTable =
{
    [0] = {0, -1, 0}, -- North
    [1] = {1, 0, 0}, -- East
    [2] = {0, 1, 0}, -- South
    [3] = {-1, 0, 0}, -- West
}

local sideToRot =
{
    North = 0,
    East = 1,
    South = 2,
    West = 3,
}

---@return [ [integer, integer, integer], integer]
local function loadRotPos()
    local file = fs.open('/var/lib/geotrack/state', 'rb')
    if not file then
        error('Unable to load GeoTrack. State is not initialized')
    end
    local value = file:read(2048)
    return ser.unserialize(value --[[@as string]])
end

---@param state [ [integer, integer, integer], integer]
local function saveRotPos(state)
    local file = fs.open('/var/lib/geotrack/state', 'wb')

    if not file then
        error('GeoTrack crashed. State is corrupted.')
    end

    file:write(ser.serialize(state))
    file:close()
end

---@type [ [integer, integer, integer], integer] | nil
local State

---@param rot integer
---@return [integer, integer]
function module.rotToVec(rot)
    return rotToVecTable[rot]
end

---comment
---@param funcName string
---@param addPos? [integer, integer, integer]
---@param addRot? integer
---@return boolean | nil, string?
local function callEnergyFunc(funcName, addPos, addRot)
    if not hasRobot then
        return nil, 'Unsupported on non-robots'
    end

    if require('computer').energy() < 200 then
        return nil, 'Insufficient amount of energy'
    end

    if not State then State = loadRotPos() end
    
    ---@type boolean?, string?
    local ret, err = robot[funcName]()

    if ret then
        if addPos then
            State[1][1] = State[1][1] + addPos[1]
            State[1][2] = State[1][2] + addPos[2]
            State[1][3] = State[1][3] + addPos[3]
        end
        
        if addRot then
            State[2] = (4 + State[2] + addRot) % 4
        end

        saveRotPos(State)
    end
    return ret, err
end

function module.up() return callEnergyFunc('up', {0,0,1}) end
function module.down() return callEnergyFunc('down', {0,0,-1}) end

function module.forward()
    if not State then State = loadRotPos() end
    return callEnergyFunc('forward', rotToVecTable[State[1]])
end

function module.back()
    if not State then State = loadRotPos() end
    return callEnergyFunc('back', rotToVecTable[(State[1] + 2) % 4])
end

function module.turnLeft() return callEnergyFunc('turnLeft',nil,-1) end
function module.turnRight() return callEnergyFunc('turnRight',nil,1) end
function module.turnAround() return callEnergyFunc('turnAround',nil,2) end

---@return [ [integer, integer, integer], integer]
function module.getState()
    if not State then State = loadRotPos() end
    return State
end

function module.setState(state)
    State = state
    saveRotPos(State)
end

---@param side 'North' | 'South' | 'East' | 'West'
---@return integer?, string?
function module.sideToRot(side)
    local ret = sideToRot[side]
    if not ret then
        return nil, 'Unknown side'
    end
    return ret
end

return module
