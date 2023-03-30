return {
    bars = {
        {
            modifierKey = nil,
            buttons = {
                {
                    key = '1',
                    label = 'Seigan',
                    iconPath = 'pve/07_SAM/Iaijutsu.png',
                    macro = [[
                        /recast "Seigan"
                        /ja "Seigan" <me>
                    ]]
                },
                {
                    key = '2',
                    label = 'Hasso',
                    iconPath = 'pve/07_SAM/hissatsu_shinten.png',
                    macro = [[
                        /recast "Hasso"
                        /ja "Hasso" <me>
                    ]]
                },
                {
                    key = '3',
                    label = 'Berserk',
                    iconPath = 'pve/02_WAR/berserk.png',
                    macro = [[
                        /recast "Berserk"
                        /ja "Berserk" <me>
                    ]]
                },
                {
                    key = '4',
                    label = 'Enpi',
                    iconPath = 'pve/07_SAM/enpi.png',
                    macro = [[
                        /equipset 22 echo
                        /ws "Tachi: Enpi" <t>
                        /wait 2
                        /equipset 21 echo
                    ]]
                },
                {
                    key = '5',
                    label = 'Provoke',
                    iconPath = 'pve/02_WAR/TankRollAction/provoke.png',
                    macro = [[
                        /recast "Provoke"
                        /ja "Provoke" <t>
                    ]]
                },
                {
                    key = '6',
                    label = 'Tachi: Enpi',
                    iconPath = 'pve/07_SAM/enpi.png',
                    macro = [[
                        /equipset 22 echo
                        /ws "Penta Thrust" <t>
                        /wait 2
                        /equipset 21 echo
                    ]]
                },
            }
        },
        {
            modifierKey = 'shift',
            buttons = {
                {
                    key = '1',
                    label = 'Utsusemi',
                    iconPath = 'pve/09_NIN/shade_shift.png',
                    macro = [[
                        /recast "Utsusemi: Ichi"
                        /nin "Utsusemi: Ichi" <me>
                    ]]
                },
                {
                    key = '2',
                    label = 'Check',
                    iconPath = 'actions_traits/02_General/decipher.png',
                    macro = [[
                        /check
                    ]]
                },
                {
                    key = '3',
                    label = 'Third Eye',
                    iconPath = 'pve/07_SAM/third_eye.png',
                    macro = [[
                        /recast "Third Eye"
                        /ja "Third Eye" <me>
                    ]]
                },
                {
                    key = '4',
                    label = 'Sneak Attack',
                    iconPath = 'pve/09_NIN/trick_attack.png',
                    macro = [[
                        /recast "Sneak Attack"
                        /ja "Sneak Attack" <me>
                    ]]
                },
                {
                    key = '5',
                    label = 'Meditate',
                    iconPath = 'pve/07_SAM/meditate.png',
                    macro = [[
                        /recast "Meditate"
                        /ja "Meditate" <me>
                    ]]
                }
            }
        }
    }
}
