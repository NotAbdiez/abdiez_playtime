fx_version 'cerulean'
game 'gta5'

shared_script 'cfg/config.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}
