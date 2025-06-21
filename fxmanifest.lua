fx_version "cerulean"
game "gta5"
lua54 "yes"
version "2.2.2"

shared_scripts {
    "@ox_lib/init.lua", -- Progressbar & skillcheck
    "config.lua",
    "imports.lua",
    "internals/internals.lua",
}

ui_page "javascript/index.html"

files {
    "imports.lua",
    "formatting/**/shared.lua",
    "functions/**/client.lua",
    "functions/**/shared.lua",
    "translations.lua",
    "systems/*.lua",

    "javascript/index.html",
    "javascript/*.js",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "functions/callback/server.lua",
    "internals/**/server.lua",

    "functions/debug/shared.lua",
}

client_scripts {
    "functions/callback/client.lua",
    "functions/debug/shared.lua",
    "internals/**/client.lua"
}

dependencies {
    "ox_lib", -- Skillcheck
}