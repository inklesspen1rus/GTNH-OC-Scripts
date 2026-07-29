local args = { ... }

---@class ComponentLibrary
local component = _G.require('component')

---@class EventLibrary
local event = _G.require('event')

local me_out = component.me_interface
local me_in = component.me_controller

local possible_craftibles = me_in.getCraftables()

---@param itemstack ItemStack
local function itemstack_to_string(itemstack)
    return itemstack.name .. tostring(itemstack.damage) .. '\r\n' .. (itemstack.tag or '')
end

---@type table<string, AECraftable>
local look_for = {}
for _, craftible in pairs(possible_craftibles) do
    local is = craftible.getItemStack()
    look_for[itemstack_to_string(is)] = craftible
    print('Registered', is.label)
end

---@param cpus AECpuMetadata[]
local function free_cpu_count(cpus)
    local s = 0
    for _, cpu in pairs(cpus) do
        if not cpu.busy then
            s = s + 1
        end
    end
    return s
end

while 1 do
    if me_in.allItems()() then
        local cpus = me_in.getCpus()
        local free_cpus = free_cpu_count(cpus)

        if free_cpus > 0 then
            local allWanted = {}
            local allCrafting = {}

            for _, cpu in pairs(cpus) do
                if cpu.busy then
                    local activeItems = cpu.cpu.activeItems()
                    for _, wanted in pairs(activeItems) do
                        local key = itemstack_to_string(wanted)
                        if look_for[key] and wanted.size > 0 then
                            allCrafting[key] = wanted.size + (allWanted[key] or 0)
                        end
                    end
                end
            end

            local cpus = me_out.getCpus()
            for _, cpu in pairs(cpus) do
                if cpu.busy then
                    local activeItems = cpu.cpu.activeItems()
                    for _, wanted in pairs(activeItems) do
                        local key = itemstack_to_string(wanted)
                        if look_for[key] and wanted.size > 0 then
                            allWanted[key] = wanted.size + (allWanted[key] or 0)
                        end
                    end
                end
            end

            for itemKey, wantedSize in pairs(allWanted) do
                local neededSize = wantedSize - (allCrafting[itemKey] or 0)
                if neededSize > 0 then
                    local c = look_for[itemKey]
                    local req = c.request(neededSize)

                    os.sleep(0.05)
                    while req.isComputing() do
                        os.sleep(0.05)
                    end

                    if req.hasFailed() then
                        print('Failed to craft', neededSize, c.getItemStack().label)
                    else
                        print('Requested', neededSize, c.getItemStack().label)
                    end
                end
            end
        end
    end

    if event.pull(3, 'interrupted') then return end
end