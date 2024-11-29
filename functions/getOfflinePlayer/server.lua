---@param identifier CharacterIdentifier
function Functions.getOfflinePlayer(identifier)
    if (Framework == "QB") then return QB.Functions.GetOfflinePlayerByCitizenId(identifier) end

    if (Framework == "ESX") then
        local query = [[
            SELECT
                `identifier`, `firstname`, `lastname`, `dateofbirth`, `sex`,
                `accounts`, `inventory`, `loadout`, `position`, `skin`, `skin`, `status`, `metadata`
            FROM
                users
            WHERE
                identifier = ?
            LIMIT 1
        ]]

        local row = MySQL.single.await(query, {identifier})

        if (not row) then return nil end

        return {
            identifier = row.identifier,
            firstname = row.firstname,
            lastname = row.lastname,
            dateofbirth = row.dateofbirth,
            sex = row.sex,
            accounts = json.decode(row.accounts),
            inventory = json.decode(row.inventory),
            loadout = json.decode(row.loadout),
            position = json.decode(row.position),
            skin = json.decode(row.skin),
            status = json.decode(row.status),
            metadata = json.decode(row.metadata) or {},
        }
    end


    return nil
end

return Functions.getOfflinePlayer