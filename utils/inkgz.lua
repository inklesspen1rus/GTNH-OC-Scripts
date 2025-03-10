local component = require('component')
local data = component.data
local flate_header = string.char(120, 1)

module = {}

function module.decompress(gz)
    -- Not so good GZip header cutter but works for compressed NBT data
    local compressed_data = string.sub(gz, 11, string.len(gz) - 18)
    return data.inflate(flate_header .. compressed_data)
end

return module