fx_version 'bodacious'
game 'gta5'

client_script 'client.lua'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server.lua',	
	'config.lua',
	'common.lua'
}