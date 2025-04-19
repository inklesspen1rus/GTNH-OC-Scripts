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
    workdir = '/home/netrunner-example',
    command = 'cat',
    args = {'cheat.sh'}
    files = {
        ['cheat.sh'] = 'cheat.sh'
    }
}]])
end

local config = loadfile(args[2])()
---@cast config netrunner.Config

local shell = require('shell')

shell.execute('rm', {}, '-rf', config.workdir)
shell.execute('mkdir', {}, config.workdir)

for filename, url in pairs(config.files) do
    local success, error = shell.execute('wget', {PWD=config.workdir}, '-f', url, filename)
    if not success then
        print(error)
        return
    end
end

shell.execute(config.command, {PWD=config.workdir}, table.unpack(config.args))
