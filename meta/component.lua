---@meta component

---@class InventoryControllerComponent
---@field getStackInSlot fun(side: number, slot: number): ItemStack?
---@field getStackInInternalSlot fun(slot?: number): ItemStack?
---@field suckFromSlot fun(side:number, slot:number, count?:number):boolean, string?
---@field dropIntoSlot fun(side:number, slot:number, count?:number):boolean, string?
---@field equip fun(): boolean
local inventory_controller = {}

local geolyzer = {}

---@return table
function geolyzer.analyze() end


---@class upgrade_me.ItemStack: {}
---@field label string
---@field name string
---@field damage integer
---@field isCraftable boolean
---@field maxDamage integer
---@field maxSize integer
---@field canProvideEnergy boolean?
---@field fluid table?
---@field charge number?
---@field maxCharge number?
---@field transferLimit number?
---@field capacity number?
---@field tier number?
---@field size integer?
---@field hasTag boolean?
---@field inputs table?
---@field outputs table?
---@field tag string?

---@class upgrade_me.CPUCPUType
local CPUCPUType = {}

---@return upgrade_me.ItemStack[]
function CPUCPUType.activeItems() end

---@return boolean
function CPUCPUType.isBusy() end

---@return boolean
function CPUCPUType.pendingItems() end

---@return any?, string?
function CPUCPUType.finalOutput() end

---@return boolean
function CPUCPUType.cancel() end

---@class upgrade_me.CPUType: {}
---@field name string
---@field storage number
---@field coprocessors number
---@field busy boolean
---@field cpu upgrade_me.CPUCPUType

local upgrade_me = {}

---@return upgrade_me.CPUType[]
function upgrade_me.getCpus() end

---@return fun(): upgrade_me.ItemStack
function upgrade_me.allItems() end

---@param filter? table
---@return upgrade_me.ItemStack[]
function upgrade_me.getItemsInNetwork(filter) end


---@class upgrade_me.CraftableType
local CraftableType = {}

---@return upgrade_me.ItemStack
function CraftableType.getItemStack() end

---@class upgrade_me.RequestType
local MERequestType = {}

---@return boolean
function MERequestType.hasFailed() end

---@return boolean
function MERequestType.isCanceled() end

---@return boolean
function MERequestType.isComputing() end

---@return boolean
function MERequestType.isDone() end


---@class upgrade_me.CraftableRequest
local CraftableRequest = {}

---@return boolean, string?
function CraftableRequest.hasFailed() end

---@return boolean, string?
function CraftableRequest.isComputing() end

---@param amount integer
---@param prioritizePower? boolean
---@param cpuName? string
---@return upgrade_me.CraftableRequest
function CraftableType.request(amount, prioritizePower, cpuName) end

---@param filter table
---@return upgrade_me.CraftableType[]
function upgrade_me.getCraftables(filter) end

local internet = {}

---@class internet.Request
local internetRequest = {}

---@return boolean, string?
function internetRequest.finishConnect() end

---@param n? integer
---@return string
function internetRequest.read(n) end

---@return number code
---@return string message
---@return table headers
function internetRequest.response() end

function internetRequest.close() end

---@param url string
---@return internet.Request
function internet.request(url) end

---@return boolean
function internet.isHttpEnabled() end

local redstone = {}

---@param side integer Side
---@param value integer Redstone output
---@return integer oldValue
---@overload fun(side: integer, value: table<integer,integer>): table<integer,integer>
function redstone.setOutput(side, value) end


local gpu = {}

---@param x integer
---@param y integer
---@return string symbol
---@return number fgColor
---@return number bgColor
---@return number? fgPalleteIndex
---@return number? bgPalleteIndex
function gpu.get(x, y) end

return
{
    inventory_controller = inventory_controller,
    geolyzer = geolyzer,
    upgrade_me = upgrade_me,
    internet = internet,
    redstone = redstone,
    gpu = gpu,
}