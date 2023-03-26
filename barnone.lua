addon.name = "barnone"
addon.author = "colorglut"
addon.version = "0.1"
addon.desc = "Simple action bar addon."
addon.link = ""

require('common')
local imgui = require('imgui')
local config = require('config')
local keycodes = require('keycodes')
local bar = require('bar')

local barnone = {
    allowedMenus = {
        'playermo' -- Action menu
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

--[[
local recast = AshitaCore:GetMemoryManager():GetRecast()
local resourceManager = AshitaCore:GetResourceManager()

barnone.getAbilityRecastTime = function(abilityName)
    local ability = resourceManager:GetAbilityByName(abilityName, 0)

    if not ability then
        return nil
    end

    local timerId = recast:GetAbilityTimerId(ability.Id)
    local timer = (recast:GetAbilityTimer(timerId) / 60):round()

    if timer > 0 then
        return timer
    else
        return nil
    end
end

barnone.getSpellRecastTime = function(spellName)
    local spell = resourceManager:GetSpellByName(spellName, 0)

    if not spell then
        return nil
    end

    local timer = (recast:GetSpellTimer(spell.Index) / 60):round()

    if timer > 0 then
        return timer
    else
        return nil
    end
end
]]--

-- Credit to Velyn for this logic - borrowed from HXUI
local pGameMenu = ashita.memory.find('FFXiMain.dll', 0, "8B480C85C974??8B510885D274??3B05", 16, 0)

barnone.getCurrentMenu = function()
    local subPointer = ashita.memory.read_uint32(pGameMenu)
    local subValue = ashita.memory.read_uint32(subPointer)

    if subValue == 0 then
        return nil
    end

    local menuHeader = ashita.memory.read_uint32(subValue + 4)
    local menuName = ashita.memory.read_string(menuHeader + 0x46, 16)

    return menuName:sub(9):trim()
end

barnone.isBlockedByMenu = function()
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

barnone.drawBars = function()
    local windowFlags = bit.bor(ImGuiWindowFlags_NoDecoration, ImGuiWindowFlags_AlwaysAutoResize, ImGuiWindowFlags_NoFocusOnAppearing, ImGuiWindowFlags_NoNav, ImGuiWindowFlags_NoBackground, ImGuiWindowFlags_NoBringToFrontOnFocus)

    if imgui.Begin('barnone_bars', true, windowFlags) then
        for barIndex = #barnone.bars, 1, -1 do
            barnone.bars[barIndex]:draw()
        end

        imgui.End()
    end
end

--[[
* event: d3d_present
* desc : Event called when the Direct3D device is presenting a scene.
--]]
ashita.events.register('d3d_present', 'present_cb', function ()
    local player = AshitaCore:GetMemoryManager():GetPlayer()

    if player ~= nil and player:GetMainJob() > 0 and player:GetIsZoning() == 0 then
        barnone.drawBars()
    end
end)

--[[
* event: key_data
* desc : Event called when the addon is processing keyboard input. (DirectInput GetDeviceData)
--]]
ashita.events.register('key_data', 'key_cb', function (e)
    if e.down and not barnone.isBlockedByMenu() then
        local key = keycodes.numberKeys[e.key];

        if key then
            for i, bar in ipairs(barnone.bars) do
                if bar:pressKey(key) then
                    e.blocked = true
                end
            end
        end
    end
end)
