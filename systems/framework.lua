---@type string
local framework = nil

local systems = {
    {fileName = "es_extended", variable = "ESX", fetching = function(fileName)
        ESX = exports[fileName]:getSharedObject()
    end},
    {fileName = "qb-core", variable = "QB", fetching = function(fileName)
        QB = exports[fileName]:GetCoreObject()
    end}
}

for i = 1, #systems do
    local isStarted = GetResourceState(systems[i].fileName) == "started"

    if (isStarted) then
        systems[i].fetching(systems[i].fileName)
        framework = systems[i].variable

        -- Functions.internalDebug("Found", framework)

        break
    end
end

return framework