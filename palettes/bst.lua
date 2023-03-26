return {
    bars = {
        {
            modifierKey = nil,
            buttons = {
                {
                    key = '2',
                    label = 'Check',
                    macro = [[
                        /check
                    ]]
                },
                {
                    key = '4',
                    label = 'Raging Axe',
                    macro = [[
                        /ws "Raging Axe" <t>
                    ]]
                },
                {
                    key = '5',
                    label = 'Provoke',
                    macro = [[
                        /recast "Provoke"
                        /ja "Provoke" <t>
                    ]]
                }
            }
        },
        --[[
        {
            modifierKey = 'shift',
            buttons = {}
        }
        ]]--
    }
}
