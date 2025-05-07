local unbundle = _G.require

local intseqs = require('intseqs')
local multilinewriter = require('ar-multiline-writer')

---@module "serialization"
local ser = unbundle('serialization')

local safeCalibration =
{ -- The most safe setup to interract with player with Unicode font
    originFontScale = 2,
    fontScaleHeightRatio = 16,
    fontScaleWidthRatio = 32,
    screenWidth = 480,
    screenHeight = 270,
}

---@class ar-calibrator.Config
local defaultConfig =
{
    ---@type glasses.CalibrationConfig
    initialSetup = safeCalibration,

    ---@type fun(event_name: string): ...
    eventPuller = function (event_name)
        if not os.sleep then
            ---@type any
            local event = unbundle('Event')
            while 1 do
                local edata = table.pack(event.pull())
                if edata[1] == event_name then
                    return table.unpack(edata)
                end
            end
        else
            ---@module "event"
            local event = unbundle('event')
            return event.pull(event_name)
        end
    end,

    ---@type table<string, glasses.CalibrationConfig>
    presets =
    {
        ['16x9 Large GUI with Unicode'] =
        {
            originFontScale = .5,
            screenWidth = 480,
            screenHeight = 270,
            fontScaleWidthRatio = 4,
            fontScaleHeightRatio = 8,
        },
        ['16x9 Small GUI with Unicode'] =
        {
            originFontScale = 1,
            screenWidth = 960,
            screenHeight = 540,
            fontScaleWidthRatio = 4,
            fontScaleHeightRatio = 8,
        },
        ['16x9 Large GUI without Unicode'] =
        {
            originFontScale = .5,
            screenWidth = 480,
            screenHeight = 270,
            fontScaleWidthRatio = 6,
            fontScaleHeightRatio = 10,
        },
        ['16x9 Small GUI without Unicode'] =
        {
            originFontScale = 1,
            screenWidth = 960,
            screenHeight = 540,
            fontScaleWidthRatio = 6,
            fontScaleHeightRatio = 10,
        },
    }
}

---@param glasses glasses
---@param setup glasses.CalibrationConfig
---@param setupName string
---@return fun() dispose
local function renderChooseStep(glasses, setup, setupName)
    local seqs = intseqs.new()

    local w = glasses.addRect()
    intseqs.add(seqs, w.getID())
    w.setPosition(0, 0)
    w.setSize(setup.screenHeight, setup.screenWidth)
    w.setColor(1, 1, 1)
    w.setAlpha(1)



    local dis = multilinewriter(glasses,
        setup.fontScaleWidthRatio * 2,
        setup.fontScaleHeightRatio,
        0,
[[Выберите подходящий для вашего экрана пресет
Нажмите ЛКМ для смены пресета
Нажмите ПКМ для подтверждения
Текущий пресет: ]] .. setupName,
        setup
    )

    return function()
        dis()
        for wId in intseqs.iterNums(seqs) do
            glasses.removeObject(wId)
        end
    end
end

---@param glasses any
---@param config? ar-calibrator.Config
local function calibrate(glasses, config)
    config = config or defaultConfig
    local currentName, currentSetup = 'Safe', config.initialSetup
    
    ---@type fun(): string, glasses.CalibrationConfig
    local nextSetup
    do
        local idx = nil
        nextSetup = function()
            repeat
                idx = next(config.presets, idx)
            until idx

---@diagnostic disable-next-line: return-type-mismatch
            return idx, config.presets[idx]
        end
    end
    
    repeat
        local dis = renderChooseStep(glasses, currentSetup, currentName)
        local mode = select(6, config.eventPuller('hud_click'))
        dis()

        if mode == 0 then
            currentName, currentSetup = nextSetup()
        else
            return ser.unserialize(ser.serialize(currentSetup))
        end
    until false
end

return {
    calibrate = calibrate,
    defaultConfig = defaultConfig,
    safeCalibration = safeCalibration,
}