---@param pos vector3 | table<string, number>
---@param text string
---@param scale number? @default 0.3
---@param rgba table<string, number>? @default {r = 255, g = 255, b = 255, a = 255}
---@param font integer? 0 | 1 | 2 | 4 | 6 | 7 @default 4
function Functions.draw3dText(pos, text, scale, rgba, font)
    -- Unpack coordinates
    local x, y, z = pos.x, pos.y, pos.z

    -- Unpack rgba
    if (not rgba) then rgba = {} end
    local r = rgba.r or 255
    local g = rgba.g or 255
    local b = rgba.b or 255
    local a = rgba.a or 255

    -- Calculate screen coordinates from world coordinates
    local _, screenX, screenY = GetScreenCoordFromWorldCoord(x, y, z)

    scale = scale or 0.3
    font = font

    -- Fonts can be 0
    if (type(font) ~= "number") then font = 4 end

    SetTextScale(scale, scale)
    SetTextFont(font)
    SetTextColour(r, g, b, a)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(screenX, screenY)
end

return Functions.draw3dText