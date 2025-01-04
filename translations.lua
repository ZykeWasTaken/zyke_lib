if (ResName == LibName) then return end

local language = LibConfig.language
local translations = {}

---@param key string | table
---@param formatting table[]?
---@return string | table, string | nil
function Translate(key, formatting)
    if (key == nil) then return "MISSING KEY" end

    local translation = translations[key]
    if (not translation) then return "MISSING TRANSLATION: " .. key end

    local isTable = type(translation) == "table"
    if (not isTable) then
        if (formatting) then return translation:format(table.unpack(formatting)) end
        return translation
    end

    local msg = translation.msg
    local notiType = translation.type

    if (formatting) then
        msg = msg:format(table.unpack(formatting))
    end

    return msg, notiType
end

---@return boolean
local function dirExists()
    local num = GetNumResourceMetadata(ResName, "file")
    if (num == 0) then return false end

    for i = 1, num do
        local str = GetResourceMetadata(ResName, "file", i - 1)

        if (str:sub(1, 8) == "locales/") then
            return true
        end
    end

    return false
end

local function notFound()
    error(("Translation \"%s\" not found. (locales/%s.lua)"):format(language, language))
end

if (language == nil) then return notFound() end

if (not dirExists()) then return nil end

local foundTranslations = LoadResourceFile(ResName, ("locales/%s.lua"):format(language))
if (not foundTranslations) then return notFound() end

local func, err = load(foundTranslations, ("@@%s/locales/%s.lua"):format(ResName, language))
if (not func or err) then return notFound() end

translations = func()

return Translate, translations