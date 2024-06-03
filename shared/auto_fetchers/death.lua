DeathScript = nil

local systems = {
    {filename = "wasabi_ambulance", variable = "wasabi_ambulance"}
}

local isServer = IsDuplicityVersion()
for _, system in pairs(systems) do
    if (isServer) then
        AddEventHandler("onResourceStart", function(resourceName)
            if (resourceName == system.filename) then
                DeathScript = system.variable
            end
        end)
    else
        local resourceState = GetResourceState(system.filename)

        if (resourceState == "started") then
            DeathScript = system.variable
            return
        end
    end

    if (DeathScript) then
        Functions.Debug("Found death system: " .. DeathScript)
    end
end