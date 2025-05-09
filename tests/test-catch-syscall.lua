local function fun()
    local ser = require('serialization')
    local event = require('event')

    local function catch(func, ...)
        local t = coroutine.create(func)
        local history = {}

        local incoming = table.pack(...)
        while 1 do
            local ret = table.pack(coroutine.resume(t, table.unpack(incoming)))
            print('yield:', ser.serialize(ret, true))
            table.remove(ret, 1)

            if coroutine.status(t) ~= "dead" then
                local res = table.pack(coroutine.yield(table.unpack(ret)))
                table.insert(history, { ret, res })
                incoming = res
            else
                return ret, history
            end
        end
    end

    local ret, history = catch(function()
        event.pullFiltered(2, function() return false end)
        event.pullFiltered(2, function() return false end)
        event.pullFiltered(2, function() return false end)
    end)

    print(ser.serialize(ret, true))
    print(ser.serialize(history, true))
end

local thread = require('thread')

local t = thread.create(fun)
t:join()