local component = require('component')
local inet = component.internet

---@class netrunner.Config
---@field workdir string
---@field command string
---@field args string[]
---@field files table<string, string>

local args = table.pack(...)
if #args < 1 or (args[1] == 'run' and #args < 2) or (args[1] ~= 'run' and args[1] ~= 'genconfig') then
    print('Usage: program run [config]')
    print('Usage: program genconfig')
    return
end

if args[1] == 'genconfig' then
    print([[return {
    command = 'cat cheat.sh',
    files = {
        ['cheat.sh'] = 'https://cheat.sh/'
    }
}]])
    return
end

local config = loadfile(args[2])()
---@cast config netrunner.Config

for filename, url in pairs(config.files) do
    local code = os.execute('wget -f ' .. url .. ' ' .. filename)
    if not code then return end
end

os.execute(config.command)
