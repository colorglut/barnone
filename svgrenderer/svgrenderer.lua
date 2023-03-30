local ffi = require('ffi')
local d3d = require('d3d8')
local d3d8dev = d3d.get_device()

-- Require our header files
require('svgrenderer/include/resvg_h')

-- Returns a path to a file, relative to our addon directory
local function getRelativePath(filename)
    local path = string.format('%s\\%s', addon.path, filename)

    path = (path:gsub('/', '\\'))

    return (path:gsub('\\\\', '\\'))
end

-- Load our DLLs
local resvg = ffi.load(getRelativePath('svgrenderer/bin/resvg'))

local svgRenderer = {
    -- Font file's path relative to our addon directory
    fontPath = 'assets/fonts/roboto.ttf',
    resvgOptions = nil
}

-- Initialize our resvg options and load our font(s)
function svgRenderer.initialize()
    svgRenderer.resvgOptions = ffi.new('resvg_options*', resvg.resvg_options_create())

    local fontPath = ffi.new('const char*', getRelativePath(svgRenderer.fontPath))

    resvgCheckResponse(resvg.resvg_options_load_font_file(svgRenderer.resvgOptions, fontPath))
end

function svgRenderer.renderToTexture(svgString)
    -- Initialize our SVG rendering tree
    local tree = ffi.new('resvg_render_tree*')
    local treeBuff = ffi.new('resvg_render_tree*[1]')

    treeBuff[0] = tree

    local data = ffi.new('const char*', svgString)

    -- Parse our SVG string into the tree
    resvgCheckResponse(resvg.resvg_parse_tree_from_data(data, string.len(svgString), svgRenderer.resvgOptions, treeBuff))

    local size = ffi.new('resvg_size[1]', resvg.resvg_get_image_size(treeBuff[0]))

    size = size[0]

    local width = math.ceil(size.width)
    local height = math.ceil(size.height)

    -- Initialize our DirectX texture
    local texturePointer = ffi.new('IDirect3DTexture8*[1]')

    local response = ffi.C.D3DXCreateTexture(d3d8dev, width, height, ffi.C.D3DX_DEFAULT, ffi.C.D3DUSAGE_DYNAMIC, ffi.C.D3DFMT_A8R8G8B8, ffi.C.D3DPOOL_DEFAULT, texturePointer)

    if (response ~= ffi.C.S_OK) then
        error(('Error Creating Texture: %08X (%s)'):fmt(response, d3d.get_error(response)))
    end

    -- Lock our whole texture for drawing
    local lockResponse, lockedRect = texturePointer[0]:LockRect(0, null, ffi.C.D3DLOCK_DISCARD)

    if lockResponse ~= ffi.C.S_OK then
        error(('%08X (%s)'):fmt(lockResponse, d3d.get_error(lockResponse)))
    end

    -- Initialize our texture with 0s
    ffi.fill(lockedRect.pBits, (lockedRect.Pitch / 4) * height * 4)

    -- Determine how resvg should fit our rendered image
    local fitTo = ffi.new('resvg_fit_to[1]')

    fitTo = {resvg.RESVG_FIT_TO_TYPE_ORIGINAL, 1}

    -- Render our tree onto our texture
    resvg.resvg_render(treeBuff[0], fitTo, resvg.resvg_transform_identity(), lockedRect.Pitch / 4, height, lockedRect.pBits)

    -- Done drawing, unlock our texture
    texturePointer[0]:UnlockRect(0)

    resvg.resvg_tree_destroy(treeBuff[0])
    
    return d3d.gc_safe_release(ffi.cast('IDirect3DTexture8*', texturePointer[0]))
end

svgRenderer.initialize()

return svgRenderer