local unbundle = _G.require

---@module "component"
local component = unbundle('component')

local nbt = require('tstl-nbt.nbt')
local inkgz = require('inkgz')
local json_encode = require('json.encode')
local inv = component.inventory_controller

local itemstack = inv.getStackInInternalSlot()
if not itemstack or not itemstack.hasTag then
    print('No item or no NBT')
    return
end

local decompressedTag = inkgz.decompress(itemstack.tag)
local nbt = nbt.readFromNBT(decompressedTag)
local json = json_encode.encode(nbt)
print(json)
