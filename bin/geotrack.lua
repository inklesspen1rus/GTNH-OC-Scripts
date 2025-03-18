local geotrack = require('geotrack')
local bit = require('bit32')

---@type string[]
local args = ...

if #args ~= 5 then
    print('Usage: program save {x} {y} {z} {North|South|West|East}')
    return
end

local side, err = geotrack.sideToRot(args[5])

if not side then
    print(err)
    return
end

local state =
{
    bit.band(tonumber(args[2])),
    bit.band(tonumber(args[3])),
    bit.band(tonumber(args[4])),
    side
}

geotrack.setState(state)