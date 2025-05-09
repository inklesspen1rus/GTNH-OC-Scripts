local function once(value)
    local v = value
    return function()
        local r = v
        v = nil
        return r
    end
end

for x in once(2) do
    print(x)
end