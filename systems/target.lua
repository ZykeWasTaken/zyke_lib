---@type string
local target = nil

local systems = {
    {fileName = "ox_target", variable = "OX"},
    {fileName = "qb-target", variable = "QB"},
}

-- Check if the resource is already started, and if so, set it as active
for i = 1, #systems do
    local isStarted = GetResourceState(systems[i].fileName) == "started"

    if (isStarted) then
        target = systems[i].variable

        -- Functions.internalDebug("Found", target)

        break
    end
end

return target