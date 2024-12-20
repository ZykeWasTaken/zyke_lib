-- Only intended for online-players
---@param player Character | CharacterIdentifier | PlayerId
---@param licenseType string
---@return boolean
function Functions.hasLicense(player, licenseType)
    local translations = {
        ["QB"] = {
            ["car"] = "driver"
            -- TODO: Match ESX
        },
        ["ESX"] = {
            ["car"] = "drive",
            ["bike"] = "drive_bike",
            ["truck"] = "drive_truck"
        }
    }

    licenseType = translations[Framework][licenseType]

    if (Framework == "QB") then
        local player = Functions.getPlayerData(player)
        if (not player) then return false end

        local licenses = player.PlayerData.metadata["licences"]
        if (not licenses) then return false end

        return licenses[licenseType] or false
    elseif (Framework == "ESX") then
        local playerId = Functions.getPlayerId(player)
        if (not playerId) then return false end

        local p = promise.new()
        TriggerEvent('esx_license:getLicenses', playerId, function(licenses)
            for _, license in pairs(licenses) do
                if (license.type == licenseType) then
                    p:resolve(true)
                end
            end

            p:resolve(false)
		end)

        return Citizen.Await(p)
    end

    return false
end

return Functions.hasLicense