local systems = {
    {fileName = "ox_target", variable = "ox_target"},
    {fileName = "qb-target", variable = "qb-target"},
}

-- Track if the script is started after zyke_lib
for i = 1, #systems do
    AddEventHandler("onResourceStart", function(resourceName)
        if (resourceName == systems[i].fileName) then
            Config.Target = systems[i].variable
            Functions.Debug("Found targeting system: " .. Config.Target)
        end
    end)
end

-- Check if the resource is already started, and if so, set it as active
for i = 1, #systems do
    if (GetResourceState(systems[i].fileName) == "started") then
        Config.Target = systems[i].variable

        if (Config.Target) then
            Functions.Debug("Found targeting system: " .. Config.Target)
            return
        end
    end
end