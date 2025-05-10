local unbundle = _G.require

local args = {}

local textScale = tonumber(args[1]) or .5
local posXScale = tonumber(args[2]) or textScale * 4
local posYScale = tonumber(args[3]) or textScale * 8
local posX = tonumber(args[4]) or 160
local posY = tonumber(args[5]) or 0
local textColoring = (tonumber(args[6]) or 1) == 1
local bgColoring = (tonumber(args[6]) or 1) == 1
local accurate = (tonumber(args[7]) or 1) == 1
local safe = (tonumber(args[8]) or 1) == 1
local unsafeReplacement = args[9] or '@'
local installEventHandler = true
local coroInterval = 0.05
local yield_interval = (72 / 20) * .5 -- 0.5 tick

---@module "component"
local component = unbundle('component')
---@module "unicode"
local unicode = unbundle('unicode')
---@module "computer"
local computer = unbundle('computer')
local intseqs = require('intseqs')
local ar = component.glasses
local gpu = component.gpu

---@module "bit32"
local bit = unbundle('bit32')

local isMineOS = not os.sleep

local function runBgTask(fun, interval)
    if isMineOS then
        local event = unbundle('Event')
        event.addHandler(function() fun() end, interval)
    else
        ---@module "event"
        local event = unbundle('event')
        event.timer(interval, fun, math.huge)
    end
end

-- MineOS support
---@type fun(time: number)
local sleep = os.sleep or unbundle('Event').sleep

local w, h = gpu.getResolution()

---@param gpuColor integer
---@return number r
---@return number g
---@return number b
local function gpuColorToRGB(gpuColor)
    local b = bit.band(gpuColor, 0xFF) / 255
    local g = bit.rshift(bit.band(gpuColor, 0xFF00), 8) / 255
    local r = bit.rshift(bit.band(gpuColor, 0xFF0000), 16) / 255
    return r, g, b
end

local ar_addRect = ar.addRect;
---@param pixels [string, integer, integer][]
---@param y integer
---@param yieldIfNeeded fun()
---@return intseqs widgetIds
local function writeBackground(pixels, y, yieldIfNeeded)
    local seqs = intseqs.new()

    ---@type Rect2D?
    local lastWidget = nil
    local lastBg = 0
    local count = 0

    for x = 1, w do
        local c, _, bg = table.unpack(pixels[x])
        if not bgColoring and bg ~= 0 then bg = 0xFFFFFF end

        if lastWidget then
            if lastBg ~= bg then
                lastWidget.setSize(posYScale, count * posXScale)
                lastWidget.setAlpha(1)
                count = 1
                lastWidget = nil
                yieldIfNeeded()
            end
        end

        if not lastWidget then
            lastWidget = ar_addRect()
            lastWidget.setAlpha(0)
            lastWidget.setPosition(posX + (x - 1) * posXScale, posY + (y - 1) * posYScale)
            lastWidget.setColor(gpuColorToRGB(bg))
            lastBg = bg
            count = 0

            intseqs.add(seqs, lastWidget.getID())
        end

        count = count + 1
        yieldIfNeeded()
    end

    if lastWidget then
        lastWidget.setSize(posYScale, count * posXScale)
    end

    return seqs
end

local unicode_upper = unicode.upper
local unicode_lower = unicode.lower
local string_len = string.len

local function isBraille(chr)
    local a, b, c = string.byte(chr, 1, 3)
    return c and a == 226 and (b >= 160 and b <= 163)
end

---@param c string
---@return boolean
local function isCharSafe(c)
    if string_len(c) > 1 then
        return isBraille(c) or unicode_upper(c) ~= unicode_lower(c)
    else
        return true
    end
end

local function shouldOutput(c)
    return c ~= ' '
end

local function shouldBeginNewWord(c, fg, oldFg)
    if not shouldOutput(c) and accurate then return true end
    if safe and not isCharSafe(c) then return true end
    if shouldOutput(c) and oldFg ~= fg then return true end
    return false
end

local ar_addTextLabel = ar.addTextLabel
---@param pixels [string, integer, integer][]
---@param y integer
---@param yieldIfNeeded fun()
---@return intseqs
local function writeTextRow(pixels, y, yieldIfNeeded)
    local seqs = intseqs.new()

    ---@type Text2D?
    local lastWidget = nil
    local lastFg = 0
    local chars = {}
    local count = 0

    for x = 1, w do
        local c, fg = table.unpack(pixels[x])
        if not textColoring and fg ~= 0xFFFFFF then fg = 0 end
        if not isCharSafe(c) then c = unsafeReplacement or c end

        if lastWidget then
            if shouldBeginNewWord(c, fg, lastFg) then
                lastWidget.setText(table.concat(chars, nil, 1, count))
                lastWidget.setAlpha(1)
                count = 0
                lastWidget = nil
                yieldIfNeeded()
            end
        end

        if shouldOutput(c) then
            if not lastWidget then
                lastWidget = ar_addTextLabel()
                lastWidget.setAlpha(0)
                lastWidget.setPosition(posX + (x - 1) * posXScale, posY + (y - 1) * posYScale)
                lastWidget.setScale(textScale)
                lastWidget.setColor(gpuColorToRGB(fg))
                lastFg = fg
                count = 0

                intseqs.add(seqs, lastWidget.getID())
            end
        end

        if lastWidget then
            count = count + 1
            chars[count] = c
        end
    end

    if lastWidget then
        lastWidget.setText(table.concat(chars, nil, 1, count))
    end

    return seqs
end

local coro_yield = coroutine.yield
local coro_resume = coroutine.resume
local gpu_get = gpu.get
local ar_removeObject = ar.removeObject

---@type intseqs[]
local rowWidgets = {}

---@type thread
local coro = nil

coro = coroutine.create(function()
    ---@type [string, integer, integer][]
    local pixels = {}
    for x = 1, w do
        pixels[x] = {}
    end
    
    local begin = os.time()

    local function yieldIfNeeded()
        local curtime = os.time()
        if curtime - begin >= yield_interval then
            coro_yield()
            begin = os.time()
        end
        if computer.freeMemory() < 65536 then sleep(0) end
    end

    ar.removeAll()

    repeat
        for y = 1, h do
            local succ = pcall(function()
                local oldWIds = rowWidgets[y] or intseqs.new()

                for x = 1, w do
                    local c, fg, bg = gpu_get(x, y)
                    local row = pixels[x]
                    row[1] = c
                    row[2] = fg
                    row[3] = bg
                end

                yieldIfNeeded()

                -- local wIds1 = writeBackground(pixels, y, yieldIfNeeded)
                local wIds2 = writeTextRow(pixels, y, yieldIfNeeded)
                -- intseqs.append(wIds1, wIds2)
                rowWidgets[y] = wIds2

                for wid in intseqs.iterNums(oldWIds) do
                    ar_removeObject(wid)
                end

                yieldIfNeeded()
            end)

            if not succ then
                ar.removeAll()
                for k = 1, #rowWidgets do
                    rowWidgets[k] = intseqs.new()
                end
            end
        end
        coro_yield()
    until not installEventHandler
end)

if installEventHandler then
    runBgTask(function() coro_resume(coro) end, coroInterval)
else
    while coro_resume(coro) do sleep(coroInterval) end
end
