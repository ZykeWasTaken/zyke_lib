fx_version "cerulean"
game "gta5"
lua54 "yes"
version "2.0.23"

shared_scripts {
    "@ox_lib/init.lua", -- Progressbar
    "config.lua",
}

files {
    "formatting/**/shared.lua",
    "functions/**/client.lua",
    "functions/**/shared.lua",
    "functions/**/server.lua",
    "webhooks/*.lua",
    "translations.lua",
    "systems/*.lua",
    "javascript/index.html",
    "javascript/*.js",
}

client_scripts {
    "imports.lua",
    "functions/callback/client.lua",
    "functions/debug/shared.lua",

    "internals/states/client.lua",
    "internals/events/client.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "imports.lua",
    "internals/**/server.lua",

    "functions/debug/shared.lua",

    -- Starting resources where client just fetches the server solution
    "functions/createUniqueId/server.lua",
    "functions/hasPermission/server.lua",
    "functions/getPlayersOnJob/server.lua",
    "functions/getJobData/server.lua",
    "functions/getGangData/server.lua",
    "functions/getCharacter/server.lua",
    "functions/getVehicles/shared.lua",
    "functions/getAccountIdentifier/server.lua",
    "functions/getJobs/server.lua",
}