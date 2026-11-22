local inet = component.internet
local ae2 = component.upgrade_me
local args = ...

---@type {url:string,secretKey:string,networkId:string,interval:number}
local config = loadfile(args[1])()

function getToken()
    local req = inet.request(config.url .. 'Auth/Auth', { secretKey = config.secretKey })
    local token = ''

    while not req.finishConnect() do os.sleep(0.1) end
end

function tick()
end

while 1 do
    local succ, err = xpcall(tick, debug.traceback)
    if not succ then
        print(err)
    end
    os.sleep(config.interval)
end