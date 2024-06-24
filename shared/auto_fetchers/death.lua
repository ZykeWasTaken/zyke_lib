DeathScript = nil

local systems = {
    {filename = "wasabi_ambulance", variable = "wasabi_ambulance"}
}

-- Track if the script is started after zyke_lib
for i = 1, #systems do
    AddEventHandler("onResourceStart", function(resourceName)
        if (resourceName == systems[i].filename) then
            DeathScript = systems[i].variable
            Functions.Debug("Found death system: " .. DeathScript)
        end
    end)
end

-- Check if the resource is already started, and if so, set it as active
for i = 1, #systems do
    if (GetResourceState(systems[i].filename) == "started") then
        DeathScript = systems[i].variable

        if (DeathScript) then
            Functions.Debug("Found death system: " .. DeathScript)
            return
        end
    end
end