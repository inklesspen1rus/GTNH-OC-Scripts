---@meta robot

---@class RobotComponent
---@field turnLeft fun()
---@field turnRight fun()
---@field turnAround fun()
---@field transferTo fun(toSlot: number, amount?: number): boolean
---@field select fun(slot?: number): number
---@field count fun(slot?: number): number
---@field space fun(slot?: number): number
---@field inventorySize fun(): number
---@field drop fun(): boolean
---@field suck fun(): boolean
---@field use fun(side: number, sneaky?: boolean, duration?: number): boolean, string?
local module = {}

---@return true?, string?
function module.forward() end

---@return true?, string?
function module.back() end

---@return true?, string?
function module.up() end

---@return true?, string?
function module.down() end

---@return true?, string?
function module.place() end

---@return true?, string?
function module.placeUp() end

---@return true?, string?
function module.placeDown() end

return module