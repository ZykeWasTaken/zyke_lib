FuelScript = nil

local systems = {
    {fileName = "LegacyFuel", variable = "LegacyFuel"}
}

local isServer = IsDuplicityVersion()
for _, system in pairs(systems) do
    if (isServer) then
        AddEventHandler("onResourceStart", function(resourceName)
            if (resourceName == system.fileName) then
                FuelScript = system.variable
            end
        end)
    else
        local resourceState = GetResourceState(system.fileName)

        if (resourceState == "started") then
            FuelScript = system.variable
            return
        end
    end

    if (FuelScript) then
        Functions.Debug("Found fuel system: " .. FuelScript)
    end
end