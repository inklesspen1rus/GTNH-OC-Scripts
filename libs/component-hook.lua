local unbundle = _G.require

---@module "component"
local component = unbundle('component')

---@alias hookfun_pre fun(address: string, method: string, args: any[]): any[]|nil
---@alias hookfun_post fun(success: boolean, result: any[], address: string, method: string, args: any[])

---Bundle-proof state
---@type table<string, [hookfun_pre[], hookfun_post[]]>
local hook_obj = _G.__20250513_ComponentHook or {}

if not _G.__20250513_ComponentHook then
    local runnumber = 0

    local component_invoke = component.invoke
---@diagnostic disable-next-line: duplicate-set-field
    component.invoke = function(address, method, ...)
        local obj = hook_obj[address]
        if not obj then
            return component_invoke(address, method, ...)
        end

        local args = table.pack(...)
        for idx = #obj[1], 1, -1 do
            local v = obj[1][idx]
            if v then
                local r = v(address, method, args)
                if r ~= nil then return table.unpack(r) end
            elseif runnumber == 1 then
                table.remove(obj[1], idx)
            end
        end

        local ret = table.pack(pcall(component_invoke, address, method, table.unpack(args)))
        local success = ret[1]
        local result = table.pack(select(2, table.unpack(ret)))

        for idx = #obj[2], 1, -1 do
            local v = obj[2][idx]
            if v then
                v(success, result, address, method, args)
            elseif runnumber == 1 then
                table.remove(obj[1], idx)
            end
        end

        if not success then
            error(result[1])
        end

        return table.unpack(result)
    end

--     local component_invoke_2 = component.invoke
-- ---@diagnostic disable-next-line: duplicate-set-field
--     component.invoke = function(...)
--         runnumber = runnumber + 1
--         local ret = table.pack(pcall(component_invoke_2, ...))
--         runnumber = runnumber - 1

--         if ret[1] then
--             return select(2, ret)
--         else
--             error(ret[2])
--         end
--     end

    _G.__20250513_ComponentHook = hook_obj
end

local module = {}

---@param address string
---@param handler hookfun_pre
function module.pre(address, handler)
    local obj = hook_obj[address] or {{}, {}}
    hook_obj[address] = obj
    table.insert(obj[1], handler)
end

---@param address string
---@param handler hookfun_post
function module.post(address, handler)
    local obj = hook_obj[address] or {{}, {}}
    hook_obj[address] = obj
    table.insert(obj[2], handler)
end

---@param address string
---@param handler hookfun_pre
function module.remove_pre(address, handler)
    local obj = hook_obj[address] or {{}, {}}
    hook_obj[address] = obj
    for i, v in ipairs(obj[1]) do
        if v == handler then
---@diagnostic disable-next-line: assign-type-mismatch
            obj[1][i] = false
            return
        end
    end
end

---@param address string
---@param handler hookfun_post
function module.remove_post(address, handler)
    local obj = hook_obj[address] or { {}, {} }
    hook_obj[address] = obj
    for i, v in ipairs(obj[2]) do
        if v == handler then
---@diagnostic disable-next-line: assign-type-mismatch
            obj[2][i] = false
            return
        end
    end
end

return module