if (ResName == LibName) then return end

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

if (not dirExists()) then return nil end

local language = LibConfig.language
local baseLanguage = "en"
local translations = {}

local function notFound()
    print(("^1[ERROR] Translation \"%s\" not found. (locales/%s.lua)^1"):format(language, language))
end

if (language == nil) then
    language = baseLanguage
end

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

---@param langCode string
local function loadTranslation(langCode)
    return LoadResourceFile(ResName, ("locales/%s.lua"):format(langCode))
end

local foundTranslations = loadTranslation(language)
if (not foundTranslations) then
    notFound()

    -- Attempt to run the base language instead
    language = baseLanguage
    foundTranslations = loadTranslation(language)
    if (not foundTranslations) then
        return notFound()
    end
end

local func, err = load(foundTranslations, ("@@%s/locales/%s.lua"):format(ResName, language))
if (not func or err) then return notFound() end

-- If you are not using the English version, which is our basic language, validate that you have all translations
if (language ~= "en") then
    local baseTranslations = load(LoadResourceFile(ResName, ("locales/%s.lua"):format("en")), ("@@%s/locales/%s.lua"):format(ResName, "en"))()
    local currTranslations = func()

    local missingTranslations = {}
    for key in pairs(baseTranslations) do
        if (currTranslations[key] == nil) then
            missingTranslations[#missingTranslations+1] = key
        end
    end

    if (#missingTranslations > 0) then
        print("^1You have missing translations:^3")

        for i = 1, #missingTranslations do
            print("^1-^3 " .. missingTranslations[i])
        end

        print("^1It is recommended that you fix these.^7")
    end
end

translations = func()

return Translate, translations