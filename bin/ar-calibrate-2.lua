local unbundle = _G.require

---@class event
local event    = unbundle('event')

---@module "serialization"
local ser = unbundle('serialization')

---@module "component"
local component  = unbundle('component')

local ar = component.glasses

local function create_text(x, y, text, scale)
    scale = scale or 1

    local widget = ar.addTextLabel()
    widget.setColor(1, 1, 1)
    widget.setAlpha(1)
    widget.setPosition(x, y)
    widget.setText(text)
    widget.setScale(scale)

    local wid = widget.getID()
    return function()
        ar.removeObject(wid)
    end, widget
end

local dis1 = create_text(10, 10, "Для начала - установи моноширинный шрифт")
local dis2 = create_text(10, 30, "Обе строки ниже должны быть одинаковой длины")
local dis3 = create_text(10, 50, "ЛКМ для выхода. ПКМ для подтверждения.")
local dis4 = create_text(10, 70, "ZZZZZZZZZZZZZZZZZZZ")
local dis5 = create_text(10, 80, ";;;;;;;;;;;;;;;;;;;")
local _, _, _, _, _, approved = event.pull('hud_click')
dis1()
dis2()
dis3()
dis4()
dis5()
if approved ~= 1 then
    print('Ожидаем шрифтов')
    return;
end

local dis = create_text(0, 0, "Нажми на нижний правый угол")
local _, _, _, w, h = event.pull('hud_click')
dis()
w = w + 1
h = h + 1

print('Screen size:', w, h)

local dirs = {
    [200] = { 0, -1 },
    [203] = { -1, 0 },
    [208] = { 0, 1 },
    [205] = { 1, 0 },
    [1190017] = { 0, -10 },
    [0970030] = { -10, 0 },
    [1150031] = { 0, 10 },
    [1000032] = { 10, 0 },
}
local startX, startY = 0, 0
local dis, widget = create_text(startX, startY, "Z| Расположи с помощью стрелок текст впритык в верхний левый угол, затем нажми ЛКМ |Z")
while 1 do
    local event, _, _, k1, k2 = event.pullMultiple('hud_keyboard', 'hud_click')
    if event == 'hud_keyboard' then
        local key = k1 * 10000 + k2
        if dirs[key] ~= nil then
            startX = startX + dirs[key][1]
            startY = startY + dirs[key][2]
            widget.setPosition(startX, startY)
        end
    else
        break
    end
end
dis()

print('Text start position:', startX, startY)

local textt = "Z| Расположи с помощью стрелок текст впритык в нижний правый угол, затем нажми ЛКМ |Z"
local texttlen = utf8.len(textt)
local cW, cH = 4, 10
local x, y = w - texttlen * cW, h - cH
local dis, widget = create_text(startX + x, startY + y, textt)
local dis2, lbZ = create_text(1000, y, 'Z|')
local dis3, ltZ = create_text(1000, y, 'Z|')
local dis4, rtZ = create_text(1000, y, '|Z')
local function update_Zs()
    ltZ.setPosition(startX, startY)
    lbZ.setPosition(startX, startY + h - cH)
    rtZ.setPosition(startX + w - cW * 2, startY)
end
update_Zs()
while 1 do
    local event, _, _, k1, k2 = event.pullMultiple('hud_keyboard', 'hud_click')
    if event == 'hud_keyboard' then
        local key = k1 * 10000 + k2
        if dirs[key] ~= nil then
            x = x + dirs[key][1]
            y = y + dirs[key][2]
            widget.setPosition(x, y)
            cW = (w - x) / texttlen
            cH = (h - y)
            update_Zs()
        end
    else
        break
    end
end
dis() dis2() dis3() dis4()

print('Text end pos:', x, y)
print('Text sizes:', cW, cH)