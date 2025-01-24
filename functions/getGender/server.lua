---@param player Character | CharacterIdentifier | PlayerId
---@return "male" | "female"
function Functions.getGender(player)
    local player = Functions.getPlayerData(player)
    if (not player) then return "male" end

    if (Framework == "ESX") then return player?.variables?.sex == "m" and "male" or "female" end
    if (Framework == "QB") then return player?.PlayerData?.charinfo?.gender == 0 and "male" or "female" end

    return "male"
end

return Functions.getGender