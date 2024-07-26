Functions = {}

HoldingKeys = {}
AddEventHandler("zyke_lib:OnKeyPress", function(id)
    HoldingKeys[id] = true
end)

AddEventHandler("zyke_lib:OnKeyRelease", function(id)
    HoldingKeys[id] = nil
end)

if (GetCurrentResourceName() ~= "zyke_lib") then
    local resName = GetCurrentResourceName()
    local libVersion = GetResourceMetadata("zyke_lib", "version", 0)
    local scriptLibVersionRequired = GetResourceMetadata(resName, "z_version", 0)

    if (scriptLibVersionRequired) then
        if (libVersion == scriptLibVersionRequired) then goto continue end

        local libVersionNums = {}
        for value in string.gmatch(libVersion, "[^.]+") do
            libVersionNums[#libVersionNums+1] = tonumber(value)
        end

        local scriptRequiredNums = {}
        for value in string.gmatch(scriptLibVersionRequired, "[^.]+") do
            scriptRequiredNums[#scriptRequiredNums+1] = tonumber(value)
        end

        for i = 1, #libVersionNums do
            local libOutdated = libVersionNums[i] < scriptRequiredNums[i]

            if (libOutdated) then
                print("^1================================================================================")
                print("^3" .. resName .. " requires at least v" .. scriptLibVersionRequired .. " of zyke_lib, your version is " .. libVersion .. "!")
                print("^3This mismatch will cause the script to not work as intended, please update.")
                print("^3You can download it here: https://github.com/ZykeWasTaken/zyke_lib/releases")
                print("^1================================================================================^0")

                CreateThread(function()
                    Wait(1000)
                    while (true) do
                        print("^1Very Important!")
                        print("^3We do not perform outside checks for script versions.")
                        print("^3Your mismatching version of zyke_lib is due to a recent update in any zyke script.")
                        print("^3You can download the latest and required zyke_lib here: https://github.com/ZykeWasTaken/zyke_lib/releases^0")

                        Wait(3000)
                    end
                end)
            end
        end
    end

    ::continue::
end

Tools = {}
Translations = {}
Minigames = {}

function Fetch()
    return Functions, Tools, Translations, Minigames
end

exports("Fetch", Fetch)

Z, Tools, TranslationsHandler, Minigames = exports["zyke_lib"]:Fetch()