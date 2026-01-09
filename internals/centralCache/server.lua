-- Central cache registry for zyke_lib
-- Handles race conditions with promises and provides a single fetch point, used to prevent expensive fetching of the same data for different resources that wants it

local registry = {}

---@class CacheEntry
---@field cache any The cached data
---@field promise any Promise for race condition handling
---@field fetcher function The function to fetch data

--- Register a cached function fetcher (called by the loader for {cached = true} functions)
---@param name string Function name, ex. "getVehicleClass"
---@param fetcher function The function that fetches the data
function RegisterCachedFunction(name, fetcher)
    if (not registry[name]) then
        registry[name] = {
            cache = nil,
            promise = nil,
            fetcher = fetcher,
        }
    end
end

-- Make RegisterCachedFunction available globally for the loader
_G.RegisterCachedFunction = RegisterCachedFunction

exports("getCachedData", function(name)
    local entry = registry[name]

    if (not entry) then return nil end
    if (entry.cache ~= nil) then return entry.cache end -- Already cached? Return immediately

    -- Someone else is fetching? Wait for them
    if (entry.promise) then
        Citizen.Await(entry.promise)

        return entry.cache
    end

    -- We're the first, create promise and fetch
    entry.promise = promise.new()

    local success, result = pcall(entry.fetcher)
    if (success) then
        entry.cache = result
    else
        print(("[CENTRAL CACHE] Error fetching '%s': %s"):format(name, tostring(result)))
        entry.cache = nil
    end

    entry.promise:resolve()

    return entry.cache
end)
