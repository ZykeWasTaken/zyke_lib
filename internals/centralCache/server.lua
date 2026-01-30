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
    entry.promise = nil -- Clear the promise so future invalidations can work

    return entry.cache
end)

-- Invalidate the cache for a function, triggering a re-fetch on next getCachedData call
-- Only invalidates if we have cached data and aren't currently fetching
---@param name string @ Function name to invalidate
---@return boolean @ Whether the cache was invalidated
local function invalidateCache(name)
    local entry = registry[name]
    if (not entry) then return false end

    -- Only invalidate if we have cached data and aren't currently fetching
    if (entry.cache ~= nil and not entry.promise) then
        entry.cache = nil
        return true
    end

    return false
end

exports("invalidateCache", invalidateCache)

-- Get a value from the cache by key, with automatic re-fetch if key not found
-- If the key is not in the cache, invalidates and re-fetches once, then tries again
-- You can just grab the value from the cache directly when getting it, but using this export allows the automatic re-fetch
---@param name string @ Cache name ex. "getModelMaxSeats"
---@param key any @ The key to lookup in the cached table
---@return any | nil @ The value if found, nil otherwise
exports("getCachedValue", function(name, key)
    local cache = exports.zyke_lib:getCachedData(name)

    if (cache and cache[key] ~= nil) then return cache[key] end

    -- Not found, try invalidating and re-fetching
    if (invalidateCache(name)) then
        cache = exports.zyke_lib:getCachedData(name)
        if (cache and cache[key] ~= nil) then
            return cache[key]
        end
    end

    return nil
end)