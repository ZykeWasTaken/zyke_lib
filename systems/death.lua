local systems = {
    {fileName = "wasabi_ambulance", variable = "wasabi_ambulance"}
}

-- Check if the resource is already started, and if so, set it as active
for i = 1, #systems do
    if (GetResourceState(systems[i].fileName) == "started") then
        DeathSystem = systems[i].variable

        break
    end
end

for i = 1, #systems do
    AddEventHandler("onResourceStart", function(resName)
        if (resName == systems[i].fileName) then
            DeathSystem = systems[i].variable
        end
    end)
end