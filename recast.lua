local recast = {
    cooldowns = {
        abilities = {},
        spells = {}
    }
}

local resourceManager = AshitaCore:GetResourceManager()
local recastManager = AshitaCore:GetMemoryManager():GetRecast()

recast.updateRecasts = function()
    recast.cooldowns.abilities = {}
    recast.cooldowns.spells = {}

    local currentTime = os.clock();

    -- Abilities
    for i = 0, 31 do
        local id = recastManager:GetAbilityTimerId(i)
        local timer = recastManager:GetAbilityTimer(i) / 60

        if (id ~= 0 or i == 0) and timer > 0 then
            local ability = resourceManager:GetAbilityByTimerId(id)

            recast.cooldowns.abilities[ability.Id] = timer
        end
    end

    -- Spells
    for id = 0, 1024 do
        local timer = recastManager:GetSpellTimer(id) / 60

        if timer > 0 then
            local spell = resourceManager:GetSpellById(id)

            recast.cooldowns.spells[spell.Id] = timer
        end
    end
end

return recast