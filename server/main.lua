local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add('comserv', 'Sentance someone to community service', {{name='serverid', help='Persons Server Id'}, {name='amount', help='The amount of tasks you want the person to do'}}, false, function(source, args)
	local src = source
    local ped = GetPlayerPed(src)
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
			SentancePlayerToCommunityService(tonumber(args[1]), tonumber(args[2]))


        end
    end
end)

QBCore.Commands.Add('removeservice', 'Remove players community service', {{name='serverid', help='Persons Server Id'}}, false, function(source, args)
	local src = source
    local ped = GetPlayerPed(src)
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
			RemovePlayerCommunityService(tonumber(args[1]))
            TriggerClientEvent('client:communityservice:finishService', src)

        end
    end
end)

QBCore.Commands.Add('updatecomserv', 'Update players community service tasks', {{name='serverid', help='Persons Server Id'}, {name='amount', help='The amount of tasks you want the person to do'}}, false, function(source, args)
	local src = source
    local ped = GetPlayerPed(src)
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
			UpdatePlayerCommunityService(tonumber(args[1]), tonumber(args[2]))


        end
    end
end)

CheckIfHasCommunityService = function(Player)
    local result = exports.oxmysql:executeSync('SELECT * FROM player_communityservice WHERE citizenid = ?', { Player.PlayerData.citizenid })
    if not result[1] then
        return false
    elseif result[1] then
        return {true, result[1].taskAmount}
    end

end

SentancePlayerToCommunityService = function(playerId, tasksAmount)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player then 
        local gangs = exports.oxmysql:executeSync('SELECT * FROM player_communityservice WHERE citizenid = ?', { Player.PlayerData.citizenid })
        if not gangs[1] then
            exports.oxmysql:insert('INSERT INTO player_communityservice (license, citizenid, taskAmount) VALUES (?, ?, ?)', {
                Player.PlayerData.license,
                Player.PlayerData.citizenid,
                tasksAmount
            })
            TriggerClientEvent('communityservice:client:assignService', playerId, tasksAmount)
        elseif gangs[1] then
            print('this player already has community service')
        end
    else
        print('invalid player id')
    end
end

RemovePlayerCommunityService = function(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player then 
        exports.oxmysql:execute('DELETE FROM player_communityservice WHERE citizenid = ?', {
            Player.PlayerData.citizenid
        })
    else 
        print('invalid player id')
    end
end

UpdatePlayerCommunityService = function(playerId, newTaskAmount)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player then 
        if CheckIfHasCommunityService(Player) then 
            exports.oxmysql:execute('UPDATE player_communityservice SET taskAmount = ? WHERE citizenid = ?', {newTaskAmount, Player.PlayerData.citizenid})
        end
    else
        print('invalid player id')
    end
end

AddCommunityService = function(playerId, taskstoAdd)
    
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player then 
        if CheckIfHasCommunityService(Player) then 
            newTasksAmount = CheckIfHasCommunityService(Player)[2] + taskstoAdd
            TriggerClientEvent('client:communityservice:updateTaskamount', playerId, newTasksAmount)
            exports.oxmysql:execute('UPDATE player_communityservice SET taskAmount = ? WHERE citizenid = ?', {newTasksAmount, Player.PlayerData.citizenid})
        end
    else
        print('invalid player id')
    end
end

RegisterServerEvent('communityservice:addTasks')
AddEventHandler('communityservice:addTasks', function(tasks)
    AddCommunityService(source, tonumber(tasks))
end)


RegisterServerEvent('communityservice:updateTasks')
AddEventHandler('communityservice:updateTasks', function(tasks)
    UpdatePlayerCommunityService(source, tasks)
end)

RegisterServerEvent('communityservice:server:finishService')
AddEventHandler('communityservice:server:finishService', function()
    RemovePlayerCommunityService(source)
end)

QBCore.Functions.CreateCallback('communityservice:checkData', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local result = exports.oxmysql:executeSync('SELECT * FROM player_communityservice WHERE citizenid = ?', { Player.PlayerData.citizenid })
    if not result[1] then
        cb(false)
    elseif result[1] then
        print("RETURNING THIS BULLSHIT", result[1].taskAmount)
        cb({true, result[1].taskAmount})
    end
end)