-- An experimental custom loader to handle dependencies before loading any of the files
-- To put it shortly, this allows our resources to be started wherever in the startup sequence since we wait for dependencies to be loaded properly
-- This also ensures that the server side is always loaded before the client side

AddEventHandler("onResourceStop", function(resName)
    if (resName ~= ResName) then return end

    GlobalState[ResName .. ":loader:serverLoaded"] = false
end)

-- We need to make sure that all of our dependencies are loaded before we start loading our files
-- We also have to check if they are using our loader or not, to wait for the global state to be set
-- If the resource is labeled a dependency, it will automatically start that resource so we don't have to do anything other than waiting
-- For some reason you just can't check for "dependencies", you have to type out each dependency as "dependency" in the fxmanifest.lua and then check for it in here
local dependencyCount = GetNumResourceMetadata(GetCurrentResourceName(), "dependency")
for i = 1, dependencyCount do
    local dependency = GetResourceMetadata(GetCurrentResourceName(), "dependency", i - 1)

    -- Check if we are using our loader, and if so, wait for the global state
    -- If we are not using it, just ignore
    local isUsingLoader = GetResourceMetadata(dependency, "loader", 0) ~= nil
    if (isUsingLoader) then
        while (not GlobalState[dependency .. ":loader:serverLoaded"]) do
            Wait(100)
        end
    end
end

-- Fetch the total number of files specified in the "loader" metadata
local fileCount = GetNumResourceMetadata(GetCurrentResourceName(), "loader")

-- If we don't have any loader files, just ignore
-- We keep this for backwards compatibility
if (fileCount == 0) then
    if (Context == "server") then
        GlobalState[ResName .. ":loader:serverLoaded"] = true
    end
end

-- Check for Cfx-styled imports of files, ex. @zyke_lib/imports.lua would use the zyke_lib resource
---@param filePath string
---@return string | nil
local function getImportName(filePath)
    local isImport = filePath:sub(1, 1) == "@"
    if (isImport) then
        -- We extract the resource name for the import
        return filePath:sub(2):match("^([^/]+)")
    end
end

local contexts = {"client", "server", "shared"}

-- We allow a prefix of the <context>:x to be specified in the loader metadata
-- This is just to allow any naming conventions to be used
-- Goofy ahh code because regex didn't work for some reason, so we're using a simpler approach
---@param filePath string
---@return string | nil, "shared" | "server" | "client" | nil, string | nil @Return optional import file name to use instead of current resource name
local function extractMetadataDetails(filePath)
	filePath = filePath:gsub('^"(.-)"$', '%1')
	filePath = filePath:gsub('^[ \t]*(.-)[ \t\r]*$', '%1')

    for i = 1, #contexts do
        local context = nil

        -- Check for context:path format
        if (
            filePath:find(("^%s:"):format(contexts[i])) -- Check for context:path format
        ) then
            context = contexts[i]
            filePath = filePath:sub(context:len() + 2) -- Trim the context: from the file path
        elseif (
            filePath:find(("^%s/"):format(contexts[i])) -- Check for context/path format
            or filePath:find(("/%s/"):format(contexts[i])) -- Check for /context/path format
        ) then
            context = contexts[i]
        elseif (
            filePath:find(("%s.lua"):format(contexts[i])) -- Check for context.lua format
        ) then
            context = contexts[i]
        end

        if (context and filePath) then
            local importName = getImportName(filePath)
            if (importName) then
                filePath = filePath:sub(importName:len() + 2)
            end

            return filePath, context, importName
        end
    end

    -- If we are down here, warn that something is wrong
    return nil, nil, nil
end

local files = {}
for i = 1, fileCount do
	files[i] = GetResourceMetadata(GetCurrentResourceName(), "loader", i - 1)
end

local toLoad = {}

for i = 1, #files do
	local fileName, context, importName = extractMetadataDetails(files[i])
    if (fileName == nil) then goto continue end

    -- Make sure we are in the right context
	if (
        context == nil
        or (
            context ~= "shared"
            and context ~= Context
        )
    ) then
		goto continue
	end

    toLoad[#toLoad+1] = {
        fileName = fileName,
        context = context,
        importName = importName
    }

	::continue::
end

if (Context == "client") then
    while (not GlobalState[ResName .. ":loader:serverLoaded"]) do
        Wait(10)
    end
end

for i = 1, #toLoad do
    local fileName = toLoad[i].fileName
    local resourceName = toLoad[i].importName or GetCurrentResourceName()

	local chunk = LoadResourceFile(resourceName, fileName)
	if (not chunk) then
		error("Failed to load " .. "(" .. toLoad[i].fileName .. ")")
	end

	local func = load(chunk, ("@@%s/%s"):format(resourceName, toLoad[i].fileName))
	if (not func) then
		error("Failed to load " .. "(" .. toLoad[i].fileName .. ")")
	end

    CreateThread(function()
        func()
    end)
end

if (Context == "server") then
    GlobalState[ResName .. ":loader:serverLoaded"] = true
end