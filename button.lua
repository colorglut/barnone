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

function button:draw()
    local startPosX, startPosY = imgui.GetCursorScreenPos()

    imgui.Dummy({config.buttonWidth, config.buttonHeight})

    imgui.GetWindowDrawList():AddRectFilled(
        {
            startPosX,
            startPosY
        },
        {
            startPosX + config.buttonWidth,
            startPosY + config.buttonHeight
        },
        imgui.GetColorU32({
            1, -- red
            0, -- green
            0, -- blue
            1 -- alpha
        })
    )

    imgui.GetWindowDrawList():AddText(
        {
            startPosX,
            startPosY
        },
        IM_COL32_WHITE,
        self.label
    )
end

function button:press()
    ashita.tasks.once(0, function()
        self.macro:execute()
    end)
end

return button