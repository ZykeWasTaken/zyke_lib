DeathScript = nil

local systems = {
    {filename = "wasabi_ambulance", variable = "wasabi_ambulance"}
}

for _, system in pairs(systems) do
    AddEventHandler("onResourceStart", function(resourceName)
        if (resourceName == system.filename) then
            Functions.Debug("Found death system: " .. system.filename)
            DeathScript = system.variable
        end
    end)
end