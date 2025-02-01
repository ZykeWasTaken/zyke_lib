local systems = {
    {fileName = "es_extended", variable = "ESX", fetching = function(fileName)
        ESX = exports[fileName]:getSharedObject()
    end},
    {fileName = "qb-core", variable = "QB", fetching = function(fileName)
        QB = exports[fileName]:GetCoreObject()
    end}
}

for i = 1, #systems do
    if (GetResourceState(systems[i].fileName) == "started") then
        systems[i].fetching(systems[i].fileName)
        Framework = systems[i].variable

        break
    end
end

-- No event catching, since this should definitely be started properly