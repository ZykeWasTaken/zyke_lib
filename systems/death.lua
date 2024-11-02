local system = nil

local systems = {
    {fileName = "wasabi_ambulance", variable = "wasabi_ambulance"}
}

-- Check if the resource is already started, and if so, set it as active
for i = 1, #systems do
    local isStarted = GetResourceState(systems[i].fileName) == "started"

    if (isStarted) then
        system = systems[i].variable

        -- Functions.internalDebug("Found", system)

        break
    end
end

return system