---@class FormattedCharacter
---@field identifier string
---@field source integer
---@field firstname string
---@field lastname string
---@field birthdate string
---@field nationality string
---@field backstory string
---@field job PlayerJob

---@param player Character
---@param online boolean?
---@return FormattedCharacter | nil
function Formatting.formatCharacter(player, online)
    if (not player) then return nil end

    if (Framework == "ESX") then
        local character = {
            identifier = player.identifier,
            source = player.source,
            firstname = player.firstname or player?.variables?.firstName,
            lastname = player.lastname or player?.variables?.lastName,
            dateofbirth = player.dateofbirth or player?.variables?.dateofbirth,
            phonenumber = player.phone_number or player?.variables?.phoneNumber,
            backstory = nil, -- By default there is none
            online = online or false,

            -- Unused, future proofing
            gender = player.sex or player?.variables?.sex,
            height = player.height or player?.variables?.height,
            salary = player?.job?.grade_salary or 0

            -- To Add:
            -- Accounts
            -- Job
        }

        return character
    elseif (Framework == "QB") then
        local character = {
            identifier = player.PlayerData.citizenid,
            source = player.PlayerData.source,
            firstname = player.PlayerData.charinfo.firstname,
            lastname = player.PlayerData.charinfo.lastname,
            dateofbirth = player.PlayerData.charinfo.birthdate,
            phonenumber = player.PlayerData.charinfo.phone,
            nationality = player.PlayerData.charinfo.nationality,
            backstory = player.PlayerData.charinfo.backstory,
            online = online or false,

            -- To Add:
            -- Accounts
            -- Job
            -- Match ESX future proofing
        }

        return character
    end

    return nil
end

return Formatting.formatCharacter