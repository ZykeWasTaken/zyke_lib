Config = Config or {}

-- Set to true to enable debug messages, recommended to always keep true since it doesn't spam the console
-- It only gives relevant information such as critical errors
Config.Debug = false

-- Make sure to use the correct fetching when switching over to ESX
-- Please note that you have to disable the QBCore fetching in your framework files when switching over to ESX
-- If you're using an up to date server, ESX Legacy when this was created, use the fetching in your fxmanifest.lua, otherwise use the fetching in the unlocked files
Config.WeaponType = "item" -- "item" / "weapon", whether to remove and give the weapon as an item or as a scrollwheel weapon, most will use item hence why it's default
Config.Target = "ox_target" -- "qb-target" / "ox_target" / nil (nil = no target script)
Config.Progressbar = "ox_lib" -- "ox_lib" or "default", "default" will use the progressbar in your framework, note that if it is out of date it may not work, ox_lib is recommended to use
Config.FuelSystem = "LegacyFuel" -- "LegacyFuel" / nil (nil = no fuel system, will use default Gta natives)
Config.CustomDeathScript = false -- Support false, "wasabi_ambulance"
Config.GangScript = false -- Support false, "zyke_gangphone"

Config.Minigames = {
    ["lockpick"] = {
        active = "ox_lib_skillcheck",
        minigames = {
            ["ox_lib_skillcheck"] = {
                -- https://overextended.dev/ox_lib/Modules/Interface/Client/skillcheck
                easy = {
                    difficulty = {"easy", "easy", "easy"},
                    inputs = {"W"}
                },
                medium = {
                    difficulty = {"easy", "medium", "medium"},
                    inputs = {"A", "D"}
                },
                hard = {
                    difficulty = {"medium", "medium", "hard"},
                    inputs = {"W", "A", "S", "D"}
                },
            },
        }
    },
    ["memorize"] = {
        active = "ps-ui_thermite",
        minigames = {
            ["ps-ui_thermite"] = {
                -- https://overextended.dev/ox_lib/Modules/Interface/Client/skillcheck
                easy = {
                    time = 20,
                    gridSize = 5,
                    incorrectBlocks = 3,
                },
                medium = {
                    time = 15,
                    gridSize = 6,
                    incorrectBlocks = 3,
                },
                hard = {
                    time = 10,
                    gridSize = 7,
                    incorrectBlocks = 3,
                },
            },
        },
    },
}