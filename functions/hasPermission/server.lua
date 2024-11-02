---@param player Character | CharacterIdentifier | PlayerId
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
function Functions.hasPermission(player, permission)
    local plyId = Functions.getPlayerId(player)
    if (not plyId) then return false end

    if (Framework == "QB") then return QB.Functions.HasPermission(player, permission) end

    if (Framework == "ESX") then
        local plyPerm = ESX.GetPlayerFromId(plyId).getGroup()
        local hasPerms = plyPerm == "superadmin" or plyPerm == permission

        return hasPerms
    end

    return false
end

Z.callback.register(LibName .. ":HasPermission", function(plyId, permission)
    return Functions.hasPermission(plyId, permission)
end)

return Functions.hasPermission