require('common')
local config = require('config')
local svgRenderer = require('svgrenderer/svgrenderer')

local buttonTexture = {}

function buttonTexture.getIconUvCoordinates(enabled)
    if enabled then
        return {{0, 0}, {0.5, 1}}
    else
        return {{.5, 0}, {1, 1}}
    end
end

function buttonTexture.generateIconSvgString(iconPath)
    local filePath = string.format('%s\\%s\\%s\\%s', addon.path, 'assets', config.iconBasePath, iconPath)

    return [[
        <svg width="]] .. config.buttonWidth * 2 .. [[" height="]] .. config.buttonHeight .. [[" fill="none" xmlns="http://www.w3.org/2000/svg">
            <filter id="bgraShift">
                <feColorMatrix type="matrix"
                    values="0 0 1 0 0
                    0 1 0 0 0
                    1 0 0 0 0
                    0 0 0 1 0" />
            </filter>
            <filter id="darken">
                <feComponentTransfer>
                    <feFuncR type="linear" slope="0.2"/>
                    <feFuncG type="linear" slope="0.2"/>
                    <feFuncB type="linear" slope="0.2"/>
                    <feFuncA type="linear" slope="0.7"/>
                </feComponentTransfer>
            </filter>
            <g filter="url(#bgraShift)">
                <image href="]] .. filePath .. [[" width="]] .. config.buttonWidth .. [[" height="]] .. config.buttonHeight .. [["/>
                <image href="]] .. filePath .. [[" width="]] .. config.buttonWidth .. [[" height="]] .. config.buttonHeight .. [[" x="]] .. config.buttonWidth .. [[" filter="url(#darken)"/>
            </g>
        </svg>
    ]]
end

function buttonTexture.generateIconTexture(iconPath)
    return svgRenderer.renderToTexture(buttonTexture.generateIconSvgString(iconPath))
end

function buttonTexture.generateIconOverlaySvgString()
    return [[
        <svg width="]] .. config.buttonWidth .. [[" height="]] .. config.buttonHeight .. [[" xmlns="http://www.w3.org/2000/svg">
            <filter id="bgraShift">
                <feColorMatrix type="matrix"
                    values="0 0 1 0 0
                    0 1 0 0 0
                    1 0 0 0 0
                    0 0 0 1 0" />
            </filter>
            <filter id="inner-glow">
                <feMorphology operator="erode" radius="4"/>
                <feGaussianBlur stdDeviation="4"/>
                <feComposite operator="out" in="SourceGraphic" result="inverse" />
                <feFlood flood-color="white" result="color" />
                <feComposite operator="in" in="color" in2="inverse" result="shadow" />
            </filter>
            <g filter="url(#bgraShift)">
                <rect width="]] .. config.buttonWidth .. [[" height="]] .. config.buttonHeight .. [[" fill="black" rx="]] .. config.buttonRounding .. [[" filter="url(#inner-glow)"/>
            </g>
        </svg>
    ]]
end

function buttonTexture.generateIconOverlayTexture()
    return svgRenderer.renderToTexture(buttonTexture.generateIconOverlaySvgString(iconPath))
end

buttonTexture.iconOverlayTexture = buttonTexture.generateIconOverlayTexture()

return buttonTexture