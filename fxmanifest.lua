fx_version "cerulean"
game "gta5"
lua54 "yes"
version "2.0.30"

shared_scripts {
    "@ox_lib/init.lua", -- Progressbar
    "config.lua",
    "imports.lua",
}

files {
    -- "imports.lua",
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
    "functions/callback/client.lua",
    "functions/debug/shared.lua",
    "internals/**/client.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "internals/**/server.lua",

    "functions/debug/shared.lua",
}