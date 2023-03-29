require('common')
local command = require('command')

local function forEachLine(macro)
    return macro:gmatch('/([^\n]*%S)')
end

local macro = {}

function macro:new(macroText)
    local object = {}

    setmetatable(object, self)

    self.__index = self

    object.commands = {}

    for line in forEachLine(macroText) do
        table.append(object.commands, command:new(line))
    end

    return object
end

function macro:getRecastTime()
    local recastTime = nil

    for i, command in ipairs(self.commands) do
        local commandRecast = command:getRecastTime()

        if commandRecast and commandRecast > 0 then
            if not recastTime or recastTime > commandRecast then
                recastTime = commandRecast
            end
        end
    end

    return recastTime
end

function macro:isExecutable()
    local isExecutable = true
    
    for i, command in ipairs(self.commands) do
        if not command:isExecutable() then
            isExecutable = false
            
            break
        end
    end

    return isExecutable
end

function macro:execute()
    for i, command in ipairs(self.commands) do
        command:execute()
    end
end

return macro
