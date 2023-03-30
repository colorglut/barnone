require('common')
local ffi = require('ffi')
local imgui = require('imgui')
local config = require('config')
local macro = require('macro')
local buttonTexture = require('buttonTexture')

local button = {}

function button:new(buttonData)
    local object = {}

    setmetatable(object, self)

    self.__index = self

    object.label = buttonData.label
    object.key = buttonData.key
    object.iconPath = buttonData.iconPath

    object:renderTexture()

    object.macro = macro:new(buttonData.macro)

    return object
end

function button:renderTexture()
    if self.iconPath then
        self.texture = buttonTexture.generateIconTexture(self.iconPath)
    end
end

function button:getIconTexture()
    return tonumber(ffi.cast("uint32_t", self.texture))
end

function button:getOverlayTexture()
    return tonumber(ffi.cast("uint32_t", buttonTexture.iconOverlayTexture))
end

function button:isPressable()
    return self.macro:isExecutable()
end

function button:initiatePressAnimation()
    self.animating = true
    self.opacity = 1
end

function button:animate()
    if not self.animating then
        return
    end

    self.opacity = math.max(self.opacity - 0.05 , 0)

    if self.opacity == 0 then
        self.animating = false
    end
end

function button:draw()
    self:animate()

    local startPosX, startPosY = imgui.GetCursorScreenPos()

    imgui.Dummy({config.buttonWidth, config.buttonHeight})

    local isPressable = self:isPressable()

    if self.iconPath then
        local uvCoordinates = buttonTexture.getIconUvCoordinates(isPressable)

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
            uvCoordinates[1],
            uvCoordinates[2],
            IM_COL32_WHITE,
            config.buttonRounding
        )

        if self.animating then
            imgui.GetWindowDrawList():AddImageRounded(
                self:getOverlayTexture(),
                {
                    startPosX,
                    startPosY
                },
                {
                    startPosX + config.buttonWidth,
                    startPosY + config.buttonHeight
                },
                uvCoordinates[1],
                uvCoordinates[2],
                imgui.GetColorU32({1, 1, 1, self.opacity}),
                config.buttonRounding
            )
        end
    else
        local color

        if isPressable then
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
            imgui.GetColorU32(color),
            config.buttonRounding
        )
    end

    local label = self.label

    if string.len(label) > 5 then
        label = string.sub(label, 0, 5) .. '..'
    end

    imgui.GetWindowDrawList():AddText(
        {
            startPosX,
            startPosY + 4
        },
        imgui.GetColorU32({0, 0, 0, 1}),
        label
    )

    imgui.GetWindowDrawList():AddText(
        {
            startPosX,
            startPosY + 2
        },
        IM_COL32_WHITE,
        label
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
                startPosY + config.buttonHeight - 16
            },
            imgui.GetColorU32({0, 0, 0, 1}),
            recastTimeString
        )

        imgui.GetWindowDrawList():AddText(
            {
                startPosX,
                startPosY + config.buttonHeight - 16 - 2
            },
            IM_COL32_WHITE,
            recastTimeString
        )
    end
end

function button:press()
    if self:isPressable() then
        self:initiatePressAnimation()

        ashita.tasks.once(0, function()
            self.macro:execute()
        end)
    end
end

return button