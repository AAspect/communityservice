local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add('comserv', 'Sentance someone to community service', {{name='message', help='Sentance someone to community service'}}, false, function(source, args)
	local src = source
    local ped = GetPlayerPed(src)
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
            TriggerClientEvent('communityservice:setplayerincomserv', v.PlayerData.source, args[2])
        end
    end
end)