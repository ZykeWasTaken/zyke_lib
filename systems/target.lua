local awaitSystemStarting = ...

local systems = {
    {fileName = "ox_target", variable = "OX"},
    {fileName = "qb-target", variable = "QB"},
}

for i = 1, #systems do
    local resState = awaitSystemStarting(systems[i].fileName)

    -- If it's started, we use it
    if (resState == "started") then
        Target = systems[i].variable
        Functions.debug.internal("^2Using " .. systems[i].fileName .. " as target system^7")

        break
    end
end