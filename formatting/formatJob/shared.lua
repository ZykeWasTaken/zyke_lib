---@class JobGrade
---@field name string
---@field label string
---@field boss boolean

---@class Job
---@field name string
---@field label string
---@field grades JobGrade[]
---@field bossRanks table<string, boolean>

---@param rawJob table
---@return Job | nil
function Formatting.formatJob(rawJob)
    if (not rawJob) then return nil end

    if (Framework == "ESX") then
        local grades = {}
        local bossRanks = {}

        local highestGrade = 1
        for key, value in pairs(rawJob.grades) do
            local grade = tonumber(key) + 1

            if (grade > highestGrade) then
                highestGrade = grade
            end

            grades[grade] = {
                name = value.name,
                label = value.label,
                boss = false
            }
        end

        grades[highestGrade].boss = true
        bossRanks[grades[highestGrade].name] = true

        return {
            name = rawJob.name,
            label = rawJob.label,
            grades = grades,
            bossRanks = bossRanks
        }
    elseif (Framework == "QB") then
        local grades = {}
        local bossRanks = {}

        for key, value in pairs(rawJob.grades) do
            if (value.isboss) then
                bossRanks[value.name] = true
            end

            grades[tonumber(key) + 1] = {
                name = value.name,
                label = value.name, -- No label, just set the name
                boss = value.isboss
            }
        end

        return {
            name = rawJob.name,
            label = rawJob.label,
            grades = grades,
            bossRanks = bossRanks
        }
    end

    return nil
end

return Formatting.formatJob