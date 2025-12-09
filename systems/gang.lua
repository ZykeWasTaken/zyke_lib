local awaitSystemStarting = ...

local systems = {
    {fileName = "zyke_gangs", variable = "zyke"}
}

for i = 1, #systems do
    local resState = awaitSystemStarting(systems[i].fileName)

    -- If it's started, we use it
    if (resState == "started") then
        GangSystem = systems[i].variable
        Functions.debug.internal("^2Using " .. systems[i].fileName .. " as gang system^7")

        break
    end
end