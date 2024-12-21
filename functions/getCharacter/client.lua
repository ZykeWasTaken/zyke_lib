---@param identifier CharacterIdentifier | CharacterIdentifier[] | nil
---@return FormattedCharacter | FormattedCharacter[] | nil
---@diagnostic disable-next-line: duplicate-set-field
function Functions.getCharacter(identifier)
    -- If an identifier is not provided, use your own
    if (not identifier) then
        identifier = Z.getIdentifier()
    end

    return Functions.callback.await(ResName .. ":GetCharacter", identifier)
end

return Functions.getCharacter