-- Formatted gang list, mainly to show in UI components

---@class GangInList
---@field name string
---@field label string
---@field professionType "gang"
---@field grades GangGrade[] | nil
---@field value string

---@param labelPrefix string?
---@param labelSuffix string?
---@return GangInList[]
function Functions.getGangList(labelPrefix, labelSuffix, includeGrades)
    local gangList = {}
    local gangs = Functions.getGangs()

    for gangName, gangData in pairs(gangs) do
        local formattedGang = Formatting.formatGang(gangData)
        formattedGang.name = formattedGang?.name or gangName

        if (formattedGang) then
            gangList[#gangList+1] = {
                name = formattedGang.name,
                label = (labelPrefix or "") .. formattedGang.label .. (labelSuffix or ""),
                professionType = "gang",

                -- Optional values
                grades = includeGrades and formattedGang.grades or nil,

                -- Misc
                value = formattedGang.name, -- Same as "name", but some UI components require this key instead
            }
        end
    end

    table.sort(gangList, function(a, b)
        return a.label < b.label
    end)

    return gangList
end

return Functions.getGangList