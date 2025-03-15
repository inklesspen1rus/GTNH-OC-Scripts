---@class InventoryControllerComponent
---@field getStackInSlot fun(side: number, slot: number): ItemStack?
---@field getStackInInternalSlot fun(slot?: number): ItemStack?
---@field suckFromSlot fun(side:number, slot:number, count?:number):boolean, string?
---@field dropIntoSlot fun(side:number, slot:number, count?:number):boolean, string?
---@field equip fun(): boolean
local inventory_controller = {}

return
{
    inventory_controller = inventory_controller
}