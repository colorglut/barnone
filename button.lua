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

    imgui.GetWindowDrawList():AddRectFilled(
        {
            startPosX,
            startPosY
        },
        {
            startPosX + config.buttonWidth,
            startPosY + config.buttonHeight
        },
        imgui.GetColorU32(color)
    )

    imgui.GetWindowDrawList():AddText(
        {
            startPosX,
            startPosY
        },
        imgui.GetColorU32({0, 0, 0, 1}),
        self.label
    )
end

function button:press()
    ashita.tasks.once(0, function()
        self.macro:execute()
    end)
end

return button