---@class PlayerListPlayer
---@field name string
---@field value string
---@field label string
---@field plyId integer
---@field steamName? string
---@field license? string

---@class PlayerListExtras
---@field steamName? boolean
---@field license? boolean

---@class PlayerListOptions
---@field exclude? (CharacterIdentifier | PlayerId)[] @Array of identifiers to be excluded
---@field sortServerId? boolean
---@field allowRepeatedIdentifiers? boolean @By default, all entries will be unique
---@field extras? PlayerListExtras

---@param players? (CharacterIdentifier | PlayerId)[]
---@param options? PlayerListOptions
---@return PlayerListPlayer[]
function Functions.getPlayerList(players, options)
    if (not players or #players == 0) then return {} end

    local availablePlayers = Functions.getCharacter(players)
    if (not availablePlayers or #availablePlayers == 0) then return {} end

    options = options or {}

    ---@type PlayerListPlayer[]
    local playerList = {}
    local addedIdentifiers = {}

    for i = 1, #availablePlayers do
        local ply = availablePlayers[i]

        -- Skip repeated identifiers
        if (not options.allowRepeatedIdentifiers) then
            if (addedIdentifiers[ply.identifier] ~= nil) then goto continue end

            addedIdentifiers[ply.identifier] = true
        end

        -- Skip player if they are excluded
        if (options.exclude) then
            for j = 1, #options.exclude do
                if (options.exclude[j] == ply.identifier) then
                    goto continue
                end
            end
        end

        local firstName = ply.firstname or "MISSING FIRST NAME"
        local lastName = ply.lastname or "MISSING LAST NAME"
        local label = firstName .. " " .. lastName

        playerList[#playerList+1] = {
            label = label,
            name = ply.identifier, -- Deprecated
            identifier = ply.identifier,
            value = ply.identifier, -- Easy UI component compatibility
            plyId = ply.source,

            -- Extras
            steamName = options?.extras?.steamName and GetPlayerName(GetPlayerFromServerId(ply.source)) or nil,
            license = options?.extras?.license and Player(ply.source).state["identifier:license"],
        }

        ::continue::
    end

    if (#playerList > 1 and options.sortServerId) then
        table.sort(playerList, function(a, b)
            return a.plyId < b.plyId
        end)
    end

    return playerList
end

return Functions.getPlayerList