-- Formatted job list, mainly to show in UI components

---@class JobInList
---@field name string
---@field label string
---@field professionType "job"
---@field grades JobGrade[] | nil
---@field value string

---@param labelPrefix string?
---@param labelSuffix string?
---@return JobInList[]
function Functions.getJobList(labelPrefix, labelSuffix, includeGrades)
    local jobList = {}
    local jobs = Functions.getJobs()

    for _jobName, jobData in pairs(jobs) do
        local formattedJob = Formatting.formatJob(jobData)

        if (formattedJob) then
            if (not formattedJob.name) then -- QB
                formattedJob.name = _jobName
            end

            jobList[#jobList+1] = {
                name = formattedJob.name,
                label = (labelPrefix or "") .. formattedJob.label .. (labelSuffix or ""),
                professionType = "job",

                -- Optional values
                grades = includeGrades and formattedJob.grades or nil,

                -- Misc
                value = formattedJob.name, -- Same as "name", but some UI components require this key instead
            }
        end
    end

    table.sort(jobList, function(a, b)
        return a.label < b.label
    end)

    return jobList
end

return Functions.getJobList