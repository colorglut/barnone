require('common')
local player = require('player')
local recast = require('recast')

local resourceManager = AshitaCore:GetResourceManager()

function splitArgs(line)
    local args = {}
    
    local buff

    local quotesOpen = false

    for char in line:gmatch('.') do
        if char == '"' then
            if quotesOpen then
                table.insert(args, buff)

                buff = nil
            end

            quotesOpen = not quotesOpen
        else
            if char == ' ' and not quotesOpen then
                if buff then
                    table.insert(args, buff)
                    
                    buff = nil
                end
            elseif char ~= ' ' or quotesOpen then
                if buff then
                    buff = buff .. char
                else
                    buff = char
                end
            end
        end
    end

    if buff then
        table.insert(args, buff)
    end

    return args
end

local commandTypes = {
    WAIT = 1,
    ABILITY = 2,
    SPELL = 3,
    RANGED = 4,
    WEAPON_SKILL = 5,
    ECHO = 6,
    CHECK = 7,
    HEAL = 8,
    RECAST = 9,
    ATTACK = 10,
    EQUIPSET = 11,
    PARTY = 12
}

local commandTypeStrings = {
    [commandTypes.WAIT] = {'wait'},
    [commandTypes.ABILITY] = {'ja', 'pet'},
    [commandTypes.SPELL] = {'ma', 'magic', 'nin', 'so'},
    [commandTypes.RANGED] = {'ra', 'range', 'shoot', 'throw'},
    [commandTypes.WEAPON_SKILL] = {'ws'},
    [commandTypes.ECHO] = {'echo'},
    [commandTypes.CHECK] = {'check'},
    [commandTypes.HEAL] = {'heal'},
    [commandTypes.RECAST] = {'recast'},
    [commandTypes.ATTACK] = {'attack'},
    [commandTypes.EQUIPSET] = {'equipset'},
    [commandTypes.PARTY] = {'p', 'party'}
}

local commandRanges = {
    [commandTypes.RANGED] = 25,
    [commandTypes.ATTACK] = 30
}

local function parseCommandType(args)
    local parsedCommandType = nil

    for commandType, possibleStrings in pairs(commandTypeStrings) do
        for i, possibleString in ipairs(possibleStrings) do
            if args[1] == possibleString then
                parsedCommandType = commandType

                break
            end
        end
    end

    if not parsedCommandType then
        error(string.format('Invalid or unknown command type: %s', args[1]))
    end

    return parsedCommandType
end

local command = {}

function command:new(line)
    local object = {}

    setmetatable(object, self)

    self.__index = self

    object.line = line

    object.args = splitArgs(line)

    object.type = parseCommandType(object.args)

    return object
end

function command:getAbility()
    return resourceManager:GetAbilityByName(self.args[2], 0)
end

function command:getSpell()
    return resourceManager:GetSpellByName(self.args[2], 0)
end

function command:getManaCost()
    return self:getSpell().ManaCost
end

function command:getRecastTime()
    if self.type == commandTypes.ABILITY then
        return recast.cooldowns.abilities[self:getAbility().Id]
    elseif self.type == commandTypes.SPELL then
        return recast.cooldowns.spells[self:getSpell().Id]
    else
        return nil
    end
end

function command:getMaxRange()
    return commandRanges[self.type]
end

function command:isSelfTarget()
    return self.args[#self.args] == '<me>'
end

function command:isExecutable()
    if self.type == commandTypes.WEAPON_SKILL then
        return player:hasTarget() and player:targetIsEnemy() and player:getTP() >= 1000
    elseif self.type == commandTypes.SPELL then
        return player:getMP() >= command:getManaCost()
    elseif self.type == commandTypes.CHECK then
        return player:hasTarget()
    elseif self.type == commandTypes.RANGED or self.type == commandTypes.ATTACK then
        return player:hasTarget() and player:targetIsEnemy() and player:getTargetDistance() <= command:getMaxRange()
    elseif self.type == commandTypes.ABILITY then
        return self:getRecastTime() == nil
    else
        return true
    end
end

function command:execute()
    if self.type == commandTypes.WAIT then
        coroutine.sleep(tonumber(self.args[2]))
    else
        AshitaCore:GetChatManager():QueueCommand(-1, '/' .. self.line)
    end
end

return command