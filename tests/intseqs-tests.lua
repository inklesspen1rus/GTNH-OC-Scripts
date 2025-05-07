---@module "intseqs"
local isvm = require('libs/intseqs')

local function assert(func, msg)
    local t = type(func)
    local x = false

    if t == "function" then
        x = func()
    else
        x = not func
    end
    
    if x then
        print(debug.traceback(msg or x, 0))
        os.exit(1)
    end
end

assert(function()
    local isv = isvm.new()

    isvm.add(isv, 3)
    isvm.add(isv, 2)
    isvm.add(isv, 1)

    local t = {3, 2, 1}
    for a, b in isvm.iterSeqs(isv) do
        if a ~= t[1] then
            return 'Fuck 1'
        end

        if a ~= b then return 'Fuck 2' end
        table.remove(t, 1)
    end

    if #t > 0 then return 'Fuck 3' end

    local t = {3, 2, 1}
    for x in isvm.iterNums(isv) do
        if x ~= t[1] then
            return 'Fuck 4 ' .. x
        end

        table.remove(t, 1)
    end

    if #t > 0 then return 'Fuck 5' end
end)

assert(function()
    local isv = isvm.new()

    isvm.add(isv, 1)
    isvm.add(isv, 2)
    isvm.add(isv, 3)

    isvm.add(isv, 1)
    -- isvm.add(isv, 2)
    isvm.add(isv, 3)

    local t = {{1,3},{1,1},{3,3}}
    for a, b in isvm.iterSeqs(isv) do
        assert(a == t[1][1] and b == t[1][2], 'Fuck 01 ' .. a .. ' ' .. b)
        table.remove(t, 1)
    end

    assert(#t == 0, 'Fuck 02')

    local t = {1, 2, 3, 1, 3}
    for x in isvm.iterNums(isv) do
        if x ~= t[1] then
            return 'Fuck 04 ' .. x
        end

        table.remove(t, 1)
    end

    if #t > 0 then return 'Fuck 05' end
end)

do
    local isv = isvm.new()
    isvm.addSeq(isv, 1, 3)
    isvm.addSeq(isv, 4, 6)
    isvm.addSeq(isv, 7, 9)

    assert(isv[1] == 1 and isv[2] == 9, 'Fuck 11 ' .. isv[1] .. ' ' .. isv[2])
end

do
    local isv = isvm.new()
    isvm.addSeq(isv, 7, 9)
    isvm.addSeq(isv, 4, 6)
    isvm.addSeq(isv, 1, 3)

    assert(isv[1] == 7 and isv[2] == 9, 'Fuck 21 ' .. isv[1] .. ' ' .. isv[2])
    assert(isv[3] == 4 and isv[4] == 6, 'Fuck 22 ' .. isv[1] .. ' ' .. isv[2])
    assert(isv[5] == 1 and isv[6] == 3, 'Fuck 23 ' .. isv[1] .. ' ' .. isv[2])
end

for swap = 0, 1 do
    do
        local a = isvm.new()
        local b = isvm.new()
        local c = isvm.new()
        isvm.addSeq(a, 1, 3)
        isvm.addSeq(b, 4, 6)

        if swap then
            a, b = b, a
        end

        c = isvm.newMerged(a, b)
        assert(c[1] == 1 and c[2] == 6, swap)
    end

    do
        local a = isvm.new()
        local b = isvm.new()
        local c = isvm.new()
        isvm.addSeq(a, 1, 3)
        isvm.addSeq(b, 2, 6)

        if swap then
            a, b = b, a
        end

        c = isvm.newMerged(a, b)
        assert(c[1] == 1 and c[2] == 6, swap)
    end

    do
        local a = isvm.new()
        local b = isvm.new()
        local c = isvm.new()
        isvm.addSeq(a, 1, 6)
        isvm.addSeq(b, 1, 6)

        if swap then
            a, b = b, a
        end

        c = isvm.newMerged(a, b)
        assert(c[1] == 1 and c[2] == 6, swap)
    end

    do
        local a = isvm.new()
        local b = isvm.new()
        local c = isvm.new()
        isvm.addSeq(a, 1, 3)
        isvm.addSeq(b, 5, 6)

        if swap then
            a, b = b, a
        end

        c = isvm.newMerged(a, b)
        assert(c[1] == 1 and c[2] == 3 and c[3] == 5 and c[4] == 6, swap)
    end
end

do
    local a = isvm.new()
    local b = isvm.new()
    isvm.addSeq(a, 1, 3)
    isvm.addSeq(b, 4, 6)

    isvm.append(a, b)

    assert(a[1] == 1 and a[2] == 3, 'Fuck55')
    assert(a[3] == 4 and a[4] == 6, 'Fuck66')
end

do
    local a = isvm.new()
    local b = isvm.new()
    isvm.addSeq(b, 4, 6)

    isvm.append(a, b)

    assert(a[1] == 4 and a[2] == 6, 'Fuck66')
end
