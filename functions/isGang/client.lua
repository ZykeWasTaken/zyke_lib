---@param gangs string[] | string
---@return boolean
function Functions.isGang(gangs)
    if (type(gangs) == "string") then gangs = {gangs} end

    local plyGang = Functions.getGang()
    if (not plyGang) then return false end

    return Functions.table.contains(gangs, plyGang.name)
end

return Functions.isGang