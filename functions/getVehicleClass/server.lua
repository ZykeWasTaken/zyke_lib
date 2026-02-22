-- Vehicle class lookup, uses centralized caching

return {
    cached = true,

    -- Fetcher: runs once globally in zyke_lib's context
    fetch = function()
        local timeout = 3000
        local timeoutAdd = 500

        local status, vehClasses
        repeat
            local plyId = Functions.getRandomSpawner()
            if (not plyId) then break end

            status, vehClasses = Z.callback.request(plyId, "zyke_lib:GetVehicleClasses", {status = true, timeout = timeout})
            timeout = timeout + timeoutAdd
        until (status and status.ok == true)

        return vehClasses
    end,

    -- Getter: runs in the calling resource with local cache
    get = function(cache, model)
        -- Convert string model names to hashes since the cache uses hashes as keys
        -- Use tonumber first to handle string hashes like "418536135"
        model = tonumber(model) or joaat(model)

        return exports["zyke_lib"]:getCachedValue("getVehicleClass", model)
    end,
}