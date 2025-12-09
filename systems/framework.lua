local awaitSystemStarting = ...

local systems = {
    {fileName = "es_extended", variable = "ESX", fetching = function(fileName)
        -- Since FiveM is... FiveM... a resource is registered as started before it's actually started
        -- So we need to wrap this in a pcall because this will most likely fail and throw and error if your resource starting sequence is chaotic

        local success = false
        repeat
            success, ESX = pcall(function() return exports[fileName]:getSharedObject() end)
            Wait(50)
        until success
    end},
    {fileName = "qb-core", variable = "QB", fetching = function(fileName)
        local success = false

        repeat
            success, QB = pcall(function() return exports[fileName]:GetCoreObject() end)
            Wait(50)
        until success
    end}
}

for i = 1, #systems do
    local resState = awaitSystemStarting(systems[i].fileName)

    -- If it's started, we use it
    if (resState == "started") then
        systems[i].fetching(systems[i].fileName)
        Framework = systems[i].variable
        Functions.debug.internal("^2Using " .. systems[i].fileName .. " as framework^7")

        break
    end
end