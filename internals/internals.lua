LibName = "zyke_lib"
ResName = "zyke_lib"
Context = IsDuplicityVersion() and "server" or "client"

local function empty() end

Functions = setmetatable({
    name = LibName,
    context = Context
}, {
    __newindex = function(self, key, fn)
        rawset(self, key, fn)

        exports(key, fn)
    end,
    __index = function(self, key)
        local path = "functions"
        local contextChunk = LoadResourceFile(LibName, ("%s/%s/%s.lua"):format(path, key, Context))
        local sharedChunk = LoadResourceFile(LibName, ("%s/%s/shared.lua"):format(path, key))

        local chunk = sharedChunk or contextChunk
        local _context = sharedChunk and "shared" or Context

        if (chunk) then
            local func, err = load(chunk, ("@@%s/%s/%s/%s.lua"):format(LibName, path, key, _context))

            if (not func or err) then
                return error(err)
            end

            rawset(self, key, func() or empty)

            return self[key]
        end
    end
})

-- ##### Dependencies ##### --

---@param fileName string
---@return function
local function loadSystem(fileName)
    local chunk = LoadResourceFile(LibName, ("systems/%s.lua"):format(fileName))

    return load(chunk)()
end

loadSystem("framework")
loadSystem("inventory")
loadSystem("target")
loadSystem("gang")
loadSystem("fuel")
loadSystem("death")

-- ##### Verify Version ##### --

if (Context == "server") then
    local isOutdated, cVer, lVer = load(LoadResourceFile(LibName, ("versionchecker.lua")), ("@@%s/versionchecker.lua"):format(LibName))()
    if (type(isOutdated) == "number") then
        return print(("Could not fetch zyke_lib version. Possibly rate limited. If this persists, contact discord.gg/zykeresources. (Error %s)"):format(isOutdated))
    end

    if (isOutdated) then
        print("^3====================================================")
        print("Your zyke_lib is outdated! Please consider updating.\n")
        print(("^1Current: %s"):format(cVer))
        print(("^2Latest: %s"):format(lVer))
        print("^3====================================================^7")
    end
end