---@param text string
---@param x number? @default 0.5
---@param y number? @default 0.96
---@param scale number? @default 0.5
---@param font integer? 0 | 1 | 2 | 4 | 6 | 7 @default 4
---@param justify? "center" | "right" | "left"
function Functions.drawText(text, x, y, scale, font, justify)
    local length = x or 0.5 -- Bottom
    local height = y or 0.96 -- Center

    scale = scale or 0.5
    font = font

    -- Fonts can be 0
    if (type(font) ~= "number") then font = 4 end

    SetTextScale(scale, scale)
    SetTextFont(font)

    SetTextEdge(2, 0, 0, 0, 150)
    SetTextEntry("STRING")

    if (justify == "right") then
        SetTextRightJustify(true)
    elseif (justify == "left") then
        SetTextRightJustify(true)
    else
        SetTextCentre(true)
    end

    SetTextOutline()
    AddTextComponentString(text)
    DrawText(length, height)
end

return Functions.drawText