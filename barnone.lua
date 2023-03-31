addon.name = "barnone"
addon.author = "colorglut"
addon.version = "0.1"
addon.desc = "Simple action bar addon."
addon.link = ""

require('common')
require('utils')
local imgui = require('imgui')
local config = require('config')
local bar = require('bar')
local recast = require('recast')

local barnone = {
    pressedModifierKeys = {},
    keyCodes = {
        numberKeys = {
            [2] = '1',
            [3] = '2',
            [4] = '3',
            [5] = '4',
            [6] = '5',
            [7] = '6',
            [8] = '7',
            [9] = '8',
            [10] = '9',
            [11] = '0'
        },
    
        modifierKeys = {
            [42] = 'shift',
            [29] = 'ctrl',
            [56] = 'alt'
        }
    },
    allowedMenus = {
        'playermo' -- Action menu
    },
    hiddenMenus = {
        'fulllog', -- Expanded log window
        'map0' -- Full screen amp
    }
}

local function parsePalette(palette)
    local bars = {}

    for i, barData in ipairs(palette.bars) do
        bars[i] = bar:new(barData)
    end

    return bars
end

local palette = require('palettes/default')

barnone.bars = parsePalette(palette)

-- Credit to Velyn for this logic - borrowed from HXUI
local pGameMenu = ashita.memory.find('FFXiMain.dll', 0, "8B480C85C974??8B510885D274??3B05", 16, 0)

function barnone.getCurrentMenu()
    local subPointer = ashita.memory.read_uint32(pGameMenu)
    local subValue = ashita.memory.read_uint32(subPointer)

    if subValue == 0 then
        return nil
    end

    local menuHeader = ashita.memory.read_uint32(subValue + 4)
    local menuName = ashita.memory.read_string(menuHeader + 0x46, 16)

    return menuName:sub(9):trim()
end

function barnone.inputBlockedByMenu()
    local currentMenu = barnone.getCurrentMenu()

    if currentMenu then
        local isBlocked = true

        for i, menuName in ipairs(barnone.allowedMenus) do
            if menuName == currentMenu then
                isBlocked = false

                break
            end
        end

        return isBlocked
    else
        return false
    end
end

function barnone.hiddenByMenu()
    local currentMenu = barnone.getCurrentMenu()

    if currentMenu then
        local isHidden = false

        for i, menuName in ipairs(barnone.hiddenMenus) do
            if menuName == currentMenu then
                isHidden = true

                break
            end
        end

        return isHidden
    else
        return false
    end
end

function barnone.drawBars()
    local windowFlags = bit.bor(ImGuiWindowFlags_NoDecoration, ImGuiWindowFlags_AlwaysAutoResize, ImGuiWindowFlags_NoFocusOnAppearing, ImGuiWindowFlags_NoNav, ImGuiWindowFlags_NoBackground, ImGuiWindowFlags_NoBringToFrontOnFocus)

    if imgui.Begin('barnone_bars', true, windowFlags) then
        imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, {config.buttonSpacing, config.buttonSpacing})

        for barIndex = #barnone.bars, 1, -1 do
            barnone.bars[barIndex]:draw()
        end

        imgui.PopStyleVar(1)

        imgui.End()
    end
end

--[[
* event: d3d_present
* desc : Event called when the Direct3D device is presenting a scene.
--]]
ashita.events.register('d3d_present', 'present_cb', function ()
    local player = AshitaCore:GetMemoryManager():GetPlayer()

    if player ~= nil and player:GetMainJob() > 0 and player:GetIsZoning() == 0 and not barnone.hiddenByMenu() then
        recast.updateRecasts()

        barnone.drawBars()
    end
end)

--[[
* event: key_data
* desc : Event called when the addon is processing keyboard input. (DirectInput GetDeviceData)
--]]
ashita.events.register('key_data', 'key_cb', function (e)
    for keyId, keyName in pairs(barnone.keyCodes.modifierKeys) do
        if e.key == keyId then
            if e.down then
                table.insert(barnone.pressedModifierKeys, keyName)
            else
                tableRemove(barnone.pressedModifierKeys, keyName)
            end

            break
        end
    end

    if e.down and not barnone.inputBlockedByMenu() then
        local key = barnone.keyCodes.numberKeys[e.key]

        if key then
            local modifierKey = #barnone.pressedModifierKeys > 0 and barnone.pressedModifierKeys[1] or nil

            for i, bar in ipairs(barnone.bars) do
                if bar.modifierKey == modifierKey and bar:pressKey(key) then
                    e.blocked = true

                    break
                end
            end
        end
    end
end)
