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
    local resState = GetResourceState(systems[i].fileName)

    -- If the resource does exist but is not started yet, we need to wait for it
    -- This is a more foolproof approach to avoid having exact resource starting sequences
    if (
        resState == "starting"
        or resState == "stopping"
        or resState == "stopped"
    ) then
        while (1) do
            resState = GetResourceState(systems[i].fileName)
            if (resState == "started") then Wait(50) break end

            Functions.debug.internal("^1Waiting for " .. systems[i].fileName .. " to start...^7")
            Wait(10)
        end
    end

    -- If it's started, we use it
    if (resState == "started") then
        systems[i].fetching(systems[i].fileName)
        Framework = systems[i].variable
        Functions.debug.internal("^2Using " .. systems[i].fileName .. " as framework^7")

        break
    end
end

-- No event catching, since this should definitely be started properly