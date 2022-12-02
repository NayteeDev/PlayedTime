function notification(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(msg)
	DrawNotification(false, true)
end

local firstSpawn = false

AddEventHandler('playerSpawned', function()
	if firstSpawn == false then
		TriggerServerEvent('playtime:loggedIn', GetPlayerName(PlayerId()))
		firstSpawn = true
	end
end)

RegisterCommand('time1', function(source)
	TriggerServerEvent('playtime:loggedIn', GetPlayerName(PlayerId()))
end, false)

RegisterNetEvent('playtime:notif')
AddEventHandler('playtime:notif', function(msg)
    notification(msg)
end)