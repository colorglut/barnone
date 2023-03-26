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

function macro:execute()
    for i, command in ipairs(self.commands) do
        command:execute()
    end
end

return macro
