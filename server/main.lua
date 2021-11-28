local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add('comserv', 'Sentance someone to community service', {{name='message', help='Sentance someone to community service'}}, false, function(source, args)
	local src = source
    local ped = GetPlayerPed(src)
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
			SentanceCommunityService(tonumber(args[1]), tonumber(args[2]))
			
        end
    end
end)

QBCore.Commands.Add('removeservice', 'Remove Someones Community Service', {{name='message', help='Remove Someones Community Service'}}, false, function(source, args)
	local src = source
    local ped = GetPlayerPed(src)
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
			local Ply = Player(tonumber(args[1]))
			if Ply.state.hasTasksLeft then 

				ReleaseFromService(tonumber(args[1]))
			end
        end
    end
end)


QBCore.Commands.Add('checkservicetime', 'Check Someones Community Service', {{name='message', help='Check Someones Community Service'}}, false, function(source, args)
	local src = source
    local ped = GetPlayerPed(src)
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
			local Ply = Player(tonumber(args[1]))
			print(json.encode(Ply.state.hasTasksLeft))
        end
    end
end)



RegisterServerEvent('communityservice:checkPlayerCommunityService')
AddEventHandler('communityservice:checkPlayerCommunityService', function()
	local Ply = Player(source)
	local stillhastasksleft = Ply.state.hasTasksLeft[1]
	local tasksLeft = Ply.state.hasTasksLeft[2]
	if stillhastasksleft and tasksLeft ~= 0 then 
		SentanceCommunityService(source, Ply.state.hasTasksLeft[2])
		print('you have been send back to community service for you remaining tasks')
	end 
end)

RegisterServerEvent('communityservice:updateTasks')
AddEventHandler('communityservice:updateTasks', function(actionsRemaining)
	local src = source
	local Ply = Player(source)
	Ply.state:set('hasTasksLeft', {Ply.state.hasTasksLeft[1], actionsRemaining}, true)


end)

RegisterCommand('checkshitters',function(source)
	print(json.encode(CheckPlayerCommunityService(source)))
end, false)

CheckPlayerCommunityService = function(source)
	local Ply = Player(source)
	return Ply.state.hasTasksLeft
end

SentanceCommunityService = function(src, tasks_amount)
	local Ply = Player(src)
	Ply.state:set('hasTasksLeft', {true, tasks_amount}, true)

	TriggerClientEvent('communityservice:client:assignService', src, tonumber(tasks_amount))
end	

ReleaseFromService = function(src)
	local Ply = Player(src)
	Ply.state:set('hasTasksLeft', {false, 0}, true)
	TriggerClientEvent('communityservice:client:finishService', src)
end


RegisterServerEvent('communityservice:server:finishService')
AddEventHandler('communityservice:server:finishService', function()
	ReleaseFromService(source)
end)
