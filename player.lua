require('common')

local player = {}

local memoryManager = AshitaCore:GetMemoryManager()

local entityManager = memoryManager:GetEntity()

local targetManager = memoryManager:GetTarget()
local party = memoryManager:GetParty()

function player:getMP()
    return party:GetMemberMP(0)
end

function player:getTP()
    return party:GetMemberTP(0)
end

function player:getTargetIndex()
    return targetManager:GetTargetIndex(targetManager:GetIsSubTargetActive())
end

function player:hasTarget()
    return player:getTargetIndex() > 0
end

function player:targetIsEnemy()
    return bit.band(entityManager:GetSpawnFlags(player:getTargetIndex()), 0x10) ~= 0
end

function player:getTargetEntity()
    return memoryManager:GetEntity(self:getTargetIndex())
end

function player:getTargetDistance()
    return self:getTargetEntity().Distance
end

return player