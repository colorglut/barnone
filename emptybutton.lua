require('common')
local imgui = require('imgui')
local config = require('config')

local emptyButton = {}

function emptyButton:new(key)
    local object = {}

    setmetatable(object, self)

    self.__index = self

    object.key = key

    return object
end

function emptyButton:draw()
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
            0.5, -- red
            0.5, -- green
            0.5, -- blue
            1 -- alpha
        })
    )
end

function emptyButton:press()
end

return emptyButton