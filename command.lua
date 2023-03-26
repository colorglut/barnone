require('common')
local commandTypes = require('commandtypes')

local resourceManager = AshitaCore:GetResourceManager()

local function splitArgs(line)
    local args = {}

    for arg in line:gmatch('([^%s]+)') do
        table.insert(args, arg)
    end

    return args
end

local commandTypeStrings = {
    [commandTypes.WAIT] = {'wait'},
    [commandTypes.ABILITY] = {'ja', 'pet'},
    [commandTypes.SPELL] = {'ma', 'magic', 'nin', 'so'},
    [commandTypes.RANGED] = {'ra', 'range', 'shoot', 'throw'},
    [commandTypes.WEAPON_SKILL] = {'ws'},
    [commandTypes.ECHO] = {'echo'},
    [commandTypes.CHECK] = {'check'},
    [commandTypes.HEAL] = {'heal'}
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
    return resourceManager:GetAbilityByName(self.args[2])
end

function command:getSpell()
    return resourceMananger:GetSpellByName(self.args[2])
end

function command:getManaCost()
    return self:getSpell().ManaCost
end

function command:execute()
    if self.type == commandTypes.WAIT then
        coroutine.sleep(tonumber(self.args[2]))
    else
        AshitaCore:GetChatManager():QueueCommand(-1, '/' .. self.line)
    end
end

return command