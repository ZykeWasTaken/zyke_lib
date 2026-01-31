-- Vehicle model label lookup, uses centralized caching
-- Note that we use the auto-refetch if the key is not found, you should double check if the model is valid before calling this function
-- This is a safety measure to prevent our cache from getting stale in case people add new vehicles to the server

return {
    cached = true,

    fetch = function()
        local timeout = 3000
        local timeoutAdd = 500

        local status, modelLabels
        repeat
            -- This requires a player to be online
            local allPlys = GetPlayers()
            if (#allPlys == 0) then break end

            local plyId = math.tointeger(allPlys[math.random(1, #allPlys)])
            if (plyId) then
                status, modelLabels = Z.callback.request(plyId, "zyke_lib:GetVehicleModelLabels", {status = true, timeout = timeout})
                timeout = timeout + timeoutAdd
            end
        until (status and status.ok == true)

        return modelLabels
    end,

    -- Uses getCachedValue export which auto-refetches if key not found
    get = function(_, model)
        -- Convert string model names to hashes since the cache uses hashes as keys
        -- Use tonumber first to handle string hashes like "418536135"
        model = tonumber(model) or joaat(model)

        return exports.zyke_lib:getCachedValue("getModelLabel", model)
    end
}
