FuelScript = nil

local systems = {
    {fileName = "LegacyFuel", variable = "LegacyFuel"}
}

for _, system in pairs(systems) do
    AddEventHandler("onResourceStart", function(resourceName)
        if (resourceName == system.fileName) then
            Functions.Debug("Found fuel system: " .. system.fileName)
            FuelScript = system.variable
        end
    end)
end