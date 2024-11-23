---@class PlayerGangGrade
---@field level integer
---@field name string

---@class PlayerGang
---@field name string
---@field label string
---@field grade PlayerGangGrade

---@param rawGang table
---@return PlayerGang | nil
function Formatting.formatPlayerGang(rawGang)
    if (Framework == "ESX") then
        -- No native support for gangs, add your own resource in here
        if (not GangSystem == "zyke") then return nil end

        local formattedGang = {
            name = rawGang.id,
            label = rawGang.name,
            grade = {
                name = rawGang.rank.name,
                level = rawGang.rank.level
            }
        }

        return formattedGang
    elseif (Framework == "QB") then
        local formattedGang = {
            name = rawGang.name,
            label = rawGang.label,
            grade = {
                level = rawGang.grade.level,
                name = rawGang.grade.name,
            }
        }

        return formattedGang
    end

    return nil
end

return Formatting.formatPlayerGang