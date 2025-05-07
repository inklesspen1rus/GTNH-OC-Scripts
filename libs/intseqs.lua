---@meta intseqs

---@class intseqs

local module = {}

---@param seqvec intseqs
---@param x integer
function module.add(seqvec, x)
    ---@cast seqvec integer[]

    local idx = #seqvec
    if seqvec[idx] == (x - 1) then
        seqvec[idx] = x
    else
        seqvec[idx + 1] = x
        seqvec[idx + 2] = x
    end

end

---@param seqvec intseqs
---@return fun(): integer?, integer?
function module.iterSeqs(seqvec)
    local pos = -1
    return function()
        pos = pos + 2
        return seqvec[pos], seqvec[pos + 1]
    end
end

---@param seqvec intseqs
---@return fun(): integer?, integer?
function module.iterNums(seqvec)
    local seqPos = 2
    local curX = seqvec[1]
    if curX then curX = curX - 1 end
    return function()
        if curX ~= seqvec[seqPos] then
            curX = curX + 1
            return curX
        else
            seqPos = seqPos + 2
            curX = seqvec[seqPos - 1]
            return curX
        end
    end
end

---Adds or merges sequence
---@param seqvec intseqs
function module.addSeq(seqvec, from, to)
    local idx = #seqvec

    if seqvec[idx] ~= (from - 1) then
        seqvec[idx + 1] = from
        seqvec[idx + 2] = to
    else
        seqvec[idx] = to
    end
end

---Just appends sequences into dst
---@param dst intseqs
---@param ... intseqs
function module.append(dst, ...)
    ---@cast dst integer[]

    local idx = 0
    while 1 do
        idx = idx + 1
        local iseq = select(idx, ...)
        if not iseq then return end
        ---@cast iseq integer[]

        table.move(iseq, 1, #iseq, #dst + 1, dst)
    end
end

---Merges intseqs. Ideally works for sorted intseqs
---@param a intseqs
---@param b intseqs
function module.newMerged(a, b)
    local aPos = 1
    local bPos = 1

    local new = {}

    while 1 do
        if not a[aPos] then
            table.move(b, bPos, #b, #new + 1, new)
            return new
        end

        if not b[bPos] then
            table.move(a, aPos, #a, #new + 1, new)
            return new
        end

        if b[bPos] < a[aPos] then
            a, b = b, a
            aPos, bPos = bPos, aPos
        end

        if (b[bPos] - 1) <= a[aPos + 1] then
            --Scenario
            --a *****???
            --b   ***???
            --    ^ start within a's range
            --or
            --a ****
            --b     *???
            --      ^ b's start after a's end
            
            new[#new + 1] = math.min(b[bPos], a[aPos])
            new[#new + 1] = math.max(b[bPos + 1], a[aPos + 1])
            bPos = bPos + 2
            aPos = aPos + 2
        else
            --Scenario
            --a *****
            --b       ***
            --        ^ b's start is not near to a's end

            new[#new + 1] = a[aPos]
            new[#new + 1] = a[aPos + 1]
            aPos = aPos + 2
        end
    end
end

---@return intseqs
function module.new()
    return {}
end

return module