---@param identifier CharacterIdentifier | CharacterIdentifier[]
---@return FormattedCharacter | FormattedCharacter[] | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getCharacter(identifier)
    if (type(identifier) == "table") then
        ---@type FormattedCharacter[]
        local formattedCharacters = {}

        for i = 1, #identifier do
            formattedCharacters[#formattedCharacters+1] = Functions.getCharacter(identifier[i])
        end

        return formattedCharacters
    end

    local online = true
    local player = Functions.getPlayerData(identifier)
    if (not player) then
        player = Functions.getOfflinePlayer(identifier)
        online = false
    end

    if (not player) then return nil end

    local formattedCharacter = Formatting.formatCharacter(player, online)

    return formattedCharacter
end

Functions.callback.register(ResName .. ":GetCharacter", function(_, identifier)
    return Functions.getCharacter(identifier)
end)

return Functions.getCharacter