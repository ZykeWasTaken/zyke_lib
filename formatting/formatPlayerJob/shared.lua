---@class PlayerJobGrade
---@field level integer
---@field name string

---@class PlayerJob
---@field name string
---@field label string
---@field grade PlayerJobGrade

---@param rawJob table
---@return PlayerJob?
function Formatting.formatPlayerJob(rawJob)
    if (Framework == "ESX") then
        local formattedJob = {
            name = rawJob.name,
            label = rawJob.label,
            grade = {
                level = rawJob.grade,
                name = rawJob.grade_name
            }
        }

        return formattedJob
    elseif (Framework == "QB") then
        local formattedJob = {
            name = rawJob.name,
            label = rawJob.label,
            grade = {
                level = rawJob.grade.level,
                name = rawJob.grade.name
            }
        }

        return formattedJob
    end

    return error("Could not find framework.")
end

return Formatting.formatPlayerJob