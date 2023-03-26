require('common')
local imgui = require('imgui')
local config = require('config')
local button = require('button')
local emptyButton = require('emptybutton')

local bar = {}

function bar:new(barData)
    local object = {}

    setmetatable(object, self)

    self.__index = self

    object.buttons = {}

    for keyIndex, key in ipairs(config.keyLayout) do
        local keyHasButton = false

        for buttonIndex, buttonData in ipairs(barData.buttons) do
            if buttonData.key == key then
                object.buttons[keyIndex] = button:new(buttonData)

                keyHasButton = true
            end
        end

        if not keyHasButton then
            object.buttons[keyIndex] = emptyButton:new(key)
        end
    end

    return object
end

function bar:draw()
    for buttonIndex = 1, config.buttonCount do
        self.buttons[buttonIndex]:draw()

        if buttonIndex < config.buttonCount then
            imgui.SameLine()
        end
    end
end

function bar:pressKey(key)
    local keyPressed = false
    
    for i, buttonObject in ipairs(self.buttons) do
        if buttonObject.key == key then
            buttonObject:press()

            keyPressed = true

            break
        end
    end

    return keyPressed
end

return bar