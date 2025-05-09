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

---@class ae2-better-level.Config
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

local locks = {}
---@cast locks table<string,any>

---@param selector table
---@param count integer
---@param cpuname? string
---@return boolean
---@return string? error
local function requestCraft(selector, count, cpuname)
    local craftable = me.getCraftables(selector)
    
    if #craftable ~= 0 then
        return false, 'Ambigous selector'
    end

    craftable = craftable[1]

    local request = craftable.request(count, false, cpuname)
    while request.isComputing() do os.sleep(0.05) end

    local failed, err = request.hasFailed()
    return not failed, err
end

local function tick() end

while 1 do
    tick()
    os.sleep(5)
end
