-- Functions to handle translations
local cachedTranslations = {
    --[[
        [scriptname] = {
            [translation] = "BLA BLA BLA"
            [translation] = {msg = "BLA BLA BLA USING NOTIFICATIONS", type = "error"}
        }
    ]]
}

---@param translations table
function Translations.InitializeTranslation(translations)
    local scriptName = GetInvokingResource()

    cachedTranslations[scriptName] = translations
end

---@param key string
function Translations.Translate(key, formatting)
    local library = cachedTranslations[GetInvokingResource()]
    if (not library) then error("Attempt to translate a non-existens script library") end

    local translation = library?[key]

    -- Always return a translation to prevent script errors
    if (not translation) then
        translation = "MISSING TRANSLATION: " .. key
    end

    local isTable = type(translation) == "table"
    if (not isTable) then return translation end

    local msg = translation.msg
    local notiType = translation.type

    if (formatting) then
        msg = msg:format(table.unpack(formatting))
    end

    return msg, notiType
end