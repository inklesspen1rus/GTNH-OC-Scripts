local args = table.pack(...)
local defaultConfigName = 'ae2-level-config.lua'

local function printUsage()
    print('Usage: program serve [config]')
    print('Usage: program genconfig')
    print('Usage: program dump-craftables')
end

if #args == 0 then
    printUsage()
    return
end

if args[1] == 'genconfig' then
    print([[return{
cpumatch = '%d*%-BG%-%d*',
items={
--{level=1024,batch=16,selector={label='Stone'}},
--{level=1024,batch=16,selector={label='Stone'}},
}}]])
    return
end

if args[1] == 'dump-craftables' then
    local component = require('component')
    local comp = require('computer')
    local ser = require('serialization')
    local me = component.upgrade_me

    for item in me.allItems() do
        if item.isCraftable then
            print(ser.serialize {
                name = item.name,
                label = item.label
            })
        end

        -- Memory consumption prevention
        while comp.freeMemory() < 30000 do os.sleep(0.1) end
    end

    return
end

if args[1] ~= "serve" then
    printUsage()
    return
end

local component = require('component')
local me = component.upgrade_me
local ser = require('serialization')

---@class ae2-level.Config
---@field cpumatch string
---@field items {level: integer, batch: integer, selector: table, lock?: string}[]
local config = loadfile(args[2] or defaultConfigName)()

---@return fun(): upgrade_me.CPUType?
local function availableCpus()
    local cpus = me.getCpus()

    return function()
        while #cpus ~= 0 do
            local cpu = table.remove(cpus)
            ---@cast cpu upgrade_me.CPUType
            if string.find(cpu.name, config.cpumatch) and not cpu.busy then return cpu end
        end
    end
end

local startItem = 1

---@type table<string, any>
local lockMem = {}
-- Our crafting memory to prevent same item crafting in parallel
---@type table<table, string>
local itemCpuCraftMem = {}
---@type table<string, {level: integer, batch: integer, selector: table, lock?: string}>
local cpuItemCraftMem = {}

local function tick()
    ---@type upgrade_me.CPUType[]
    local cpus = {}

    -- Load avaliable cpus
    -- Update CraftMem
    for cpu in availableCpus() do
        if cpuItemCraftMem[cpu.name] then
            itemCpuCraftMem[cpuItemCraftMem[cpu.name]] = nil
            local itemConfig = cpuItemCraftMem[cpu.name]
            cpuItemCraftMem[cpu.name] = nil
            if itemConfig.lock then lockMem[itemConfig.lock] = nil end
        end
        table.insert(cpus, cpu)
    end

    local cpu = table.remove(cpus)
    ---@cast cpu upgrade_me.CPUType?

    for index = 1, #config.items do
        repeat
            local itemIndex = (index + startItem - 2) % #config.items + 1
            local itemConfig = config.items[itemIndex]

            if itemConfig.lock and lockMem[itemConfig.lock] then break end

            -- Do not craft if there are still active crafting
            if itemCpuCraftMem[itemConfig] ~= nil then break end

            if not cpu then
                startItem = itemIndex
                return
            end

            local itemStack = me.getItemsInNetwork(itemConfig.selector)
            -- Remove non-craftables from list
            for x = #itemStack,1, -1 do
                if not itemStack[x].isCraftable then table.remove(itemStack, x) end
            end
            if #itemStack ~= 1 then
                print('Ambigous item selector (' .. #itemStack .. '): ' .. ser.serialize(itemConfig.selector))
                break
            end
            itemStack = itemStack[1]

            if itemStack.size < itemConfig.level then
                local craftable = me.getCraftables(itemConfig.selector)
                if #craftable ~= 1 then
                    print('Item is not craftable: ' .. ser.serialize(itemConfig.selector))
                    break
                end
                craftable = craftable[1]

                local handle = craftable.request(itemConfig.batch, false, cpu.name)
                while handle.isComputing() do os.sleep(0.1) end
                
                local failed, reason = handle.hasFailed()
                if failed then
                    print('Unable to craft item "' .. itemStack.label .. '": ' .. reason)
                else
                    print('Requested craft ' .. itemStack.label)
                    itemCpuCraftMem[itemConfig] = cpu.name
                    cpuItemCraftMem[cpu.name] = itemConfig
                    if itemConfig.lock then lockMem[itemConfig.lock] = 1 end

                    cpu = table.remove(cpus)
                    ---@cast cpu upgrade_me.CPUType?
                end

            end
        until 1
    end
end

while 1 do
    tick()
    os.sleep(1)
end
