return {
    bars = {
        {
            modifierKey = nil,
            buttons = {
                {
                    key = '1',
                    label = 'Seigan',
                    macro = [[
                        /recast "Seigan"
                        /ja "Seigan" <me>
                    ]]
                },
                {
                    key = '2',
                    label = 'Hasso',
                    macro = [[
                        /recast "Hasso"
                        /ja "Hasso" <me>
                    ]]
                },
                {
                    key = '3',
                    label = 'Berserk',
                    macro = [[
                        /recast "Berserk"
                        /ja "Berserk" <me>
                    ]]
                },
                {
                    key = '4',
                    label = 'Tachi: Enpi',
                    macro = [[
                        /equipset 22 echo
                        /ws "Tachi: Enpi" <t>
                        /wait 1
                        /equipset 21 echo
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
