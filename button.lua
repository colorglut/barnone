require('common')
local imgui = require('imgui')
local config = require('config')
local macro = require('macro')

local button = {}

function button:new(buttonData)
    local object = {}

    setmetatable(object, self)

    self.__index = self

    object.label = buttonData.label
    object.key = buttonData.key

    object.macro = macro:new(buttonData.macro)

    return object
end

function button:getIconTexture()

end

function button:isPressable()
    return self.macro:isExecutable()
end

function button:draw()
    local startPosX, startPosY = imgui.GetCursorScreenPos()

    imgui.Dummy({config.buttonWidth, config.buttonHeight})

    local color

    if self.macro:isExecutable() then
        color = {0, 1, 0, 1}
    else
        color = {1, 0, 0, 1}
    end

    if self.icon then
        imgui.GetWindowDrawList():AddImageRounded(
            self:getIconTexture(),
            {
                startPosX,
                startPosY
            },
            {
                startPosX + config.buttonWidth,
                startPosY + config.buttonHeight
            },
            {0, 0},
            {1 , 1},
            IM_COL32_WHITE,
            5
        )
    else
        imgui.GetWindowDrawList():AddRectFilled(
            {
                startPosX,
                startPosY
            },
            {
                startPosX + config.buttonWidth,
                startPosY + config.buttonHeight
            },
            imgui.GetColorU32(color),
            5
        )
    end

    imgui.GetWindowDrawList():AddText(
        {
            startPosX,
            startPosY
        },
        imgui.GetColorU32({0, 0, 0, 1}),
        self.label
    )

    local recastTime = self.macro:getRecastTime()

    if recastTime then
        local recastTimeString

        if recastTime >= 1 then
            recastTimeString = tostring(math.ceil(recastTime))
        else
            recastTimeString = string.format('%.1f', recastTime)
        end

        imgui.GetWindowDrawList():AddText(
            {
                startPosX,
                startPosY + config.buttonHeight - 20
            },
            imgui.GetColorU32({0, 0, 0, 1}),
            recastTimeString
        )
    end
end

function button:press()
    ashita.tasks.once(0, function()
        self.macro:execute()
    end)
end

return button