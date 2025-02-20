local systems = {
    {fileName = "ox_target", variable = "OX"},
    {fileName = "qb-target", variable = "QB"},
}

-- Check if the resource is already started, and if so, set it as active
for i = 1, #systems do
    if (GetResourceState(systems[i].fileName) == "started") then
        Target = systems[i].variable

        break
    end
end

for i = 1, #systems do
    AddEventHandler("onResourceStart", function(resName)
        if (resName == systems[i].fileName) then
            Target = systems[i].variable

            if (Context == "server") then
                TriggerClientEvent("zyke_lib:OnSystemStart:target", -1)
            end
        end
    end)
end