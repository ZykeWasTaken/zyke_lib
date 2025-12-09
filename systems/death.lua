local awaitSystemStarting = ...

local systems = {
    {fileName = "wasabi_ambulance", variable = "wasabi_ambulance"}
}

for i = 1, #systems do
    local resState = awaitSystemStarting(systems[i].fileName)

    -- If it's started, we use it
    if (resState == "started") then
        DeathSystem = systems[i].variable
        Functions.debug.internal("^2Using " .. systems[i].fileName .. " as death system^7")

        break
    end
end