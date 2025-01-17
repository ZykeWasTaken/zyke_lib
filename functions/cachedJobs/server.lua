Functions.cachedJobs = {}

---@alias JobName string
---@alias RankName string

---@type table<CharacterIdentifier, {name: JobName, rank: RankName}>
local prevJobs = {}

local function initCachedJobs()
    ---@type table<JobName, table<CharacterIdentifier, RankName>>
    local data = {}

    ---@type function[]
    local onChangeCbs = {}

    -- Wrapping subtables with a metatable for change tracking
    ---@param tbl table
    ---@param parentKey CharacterIdentifier
    local function wrapSubTable(tbl, parentKey)
        return setmetatable(tbl or {}, {
            __newindex = function(t, key, value)
                rawset(t, key, value) -- Apply the value

                -- Run the onChange for the new values, and provide the cached values too
                if (#onChangeCbs > 0) then
                    for i = 1, #onChangeCbs do
                        onChangeCbs[i](
                            key, -- CharacterIdentifier
                            {name = parentKey, rank = value},
                            prevJobs[key] and {
                                name = prevJobs[key].name,
                                rank = prevJobs[key].rank
                            }
                        )
                    end
                end
            end
        })
    end

    -- Proxy table
    local proxy = {}
    setmetatable(proxy, {
        __index = function(_, key)
            return data[key]
        end,
        __newindex = function(_, key, newValue)
            -- If assigning a table, wrap it with a metatable
            if (type(newValue) == "table") then
                newValue = wrapSubTable(newValue, key)
            end

            data[key] = newValue
        end
    })

    function proxy.onChange(cb)
        onChangeCbs[#onChangeCbs+1] = cb
        return proxy
    end

    return proxy
end

local cachedJobs = initCachedJobs()

local function ensurePlayer(plyId, jobData)
    if (not cachedJobs[jobData.name]) then cachedJobs[jobData.name] = {} end

    local identifier = Z.getIdentifier(plyId)
    if (not identifier) then return end

    if (prevJobs[identifier]) then
        if (prevJobs[identifier].name == jobData.name and prevJobs[identifier].rank == jobData.grade.name) then return end

        cachedJobs[prevJobs[identifier].name][identifier] = nil
    end

    cachedJobs[jobData.name][identifier] = jobData.grade.name

    prevJobs[identifier] = {name = jobData.name, rank = jobData.grade.name}
end

---@param plyId PlayerId
---@param jobData PlayerJob
AddEventHandler("zyke_lib:OnJobUpdate", function(plyId, jobData)
    ensurePlayer(plyId, jobData)
end)

AddEventHandler("zyke_lib:OnCharacterSelect", function(plyId)
    local plyJob = Z.getJob(plyId)

    if (plyJob) then
        ensurePlayer(plyId, plyJob)
    end
end)

-- The default framework logout doesn't supply identifier
-- So it is a matter of timing if we can clear the old cache until we implement our own method for this
---@param plyId PlayerId
AddEventHandler("zyke_lib:OnCharacterLogout", function(plyId)
    local identifier = Z.getIdentifier(plyId)
    if (not identifier) then return false end

    if (not prevJobs[identifier]) then return end
    if (not cachedJobs[prevJobs[identifier]]) then return end

    cachedJobs[prevJobs[identifier]][identifier] = nil
    prevJobs[identifier] = nil
end)

local currPlayers = Z.getPlayers()
for i = 1, #currPlayers do
    local plyJob = Z.getJob(currPlayers[i])

    if (plyJob) then
        ensurePlayer(currPlayers[i], plyJob)
    end
end

-- Direct funcction calls to return contents
setmetatable(Functions.cachedJobs, {
    __call = function()
        return cachedJobs
    end
})

return Functions.cachedJobs