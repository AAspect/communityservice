local QBCore = exports['qb-core']:GetCoreObject()

local isInComserv = false
local comservdone = false
local TasksRemaining = 0
local availableActions = {}
  
TaskLocations = {
    { type = "sweep", coords = vector3(174.8, -989.2, 29.1), text = 'Dirty Floor, sweep it up!', textColor = {255, 255, 255} },
	{ type = "sweep", coords = vector3(162.5, -980.5, 29.1), text = 'Dirty Floor, sweep it up!', textColor = {255, 255, 255} },
	{ type = "sweep", coords = vector3(156.2, -985.3, 29.1), text = 'Dirty Floor, sweep it up!', textColor = {255, 255, 255} },
	{ type = "sweep", coords = vector3(145.2, -993.8, 28.4), text = 'Dirty Floor, sweep it up!', textColor = {255, 255, 255} },
	{ type = "sweep", coords = vector3(200.1, -1017.2, 28.3), text = 'Dirty Floor, sweep it up!', textColor = {255, 255, 255} },
	{ type = "clean", coords = vector3(173.0, -1007.7, 29.4), text = 'Dirty Meeter, Scrub it with a cloth!', textColor = {255, 255, 255} },
	{ type = "cleanfront", coords = vector3(175.6, -986.0, 31.0), text = 'Dirty Wall, wipe it down!', textColor = {255, 255, 255} },
}


AddEventHandler('QBCore:Client:OnPlayerLoaded', function() -- change this to watever
    QBCore.Functions.TriggerCallback('communityservice:checkData', function(data)
        if(data[1]) then
             TriggerEvent('communityservice:client:assignService', data[2])
        end
    end)
end)
  
FillTasksArray = function(last_action)
    while #availableActions < 1 do
        local task_not_exist = true
        local random_selection = TaskLocations[math.random(1,#TaskLocations)]
        for i = 1, #availableActions do
            if random_selection.coords == availableActions[i].coords then 
                task_not_exist = false
            end
        end
        if last_action ~= nil and random_selection.coords == last_action.coords then
            task_not_exist = false
        end
        if task_not_exist then
            table.insert(availableActions, random_selection)
        end
    end
end
  
RegisterNetEvent('communityservice:client:assignService')
AddEventHandler('communityservice:client:assignService', function(actions_remaining)
    if isInComserv then
        return
    end
    TasksRemaining = actions_remaining
    FillTasksArray()
    SetEntityCoords(PlayerPedId(), 156.08, -984.89, 30.09)
    isInComserv = true
    comservdone = false

end)
  
  
RegisterNetEvent('communityservice:client:finishService')
AddEventHandler('communityservice:client:finishService', function(source)
    Notification('You have no more tasks left! You are free!')
    comservdone = true
    isInComserv = false
    TasksRemaining = 0
end)

Citizen.CreateThread(function()
    while true do
        :: restart_thread ::
        Citizen.Wait(1)

        if TasksRemaining > 0 and isInComserv then
            local pCoords = GetEntityCoords(PlayerPedId())
        

            DrawAllAvailableTasks()


            for i = 1, #availableActions do
                local dist = #(pCoords - availableActions[i].coords)

                if dist < 1.5 then
                    if(IsControlJustReleased(1, 38))then
                        task_inProgress = availableActions[i]
                        RemoveTask(task_inProgress)
                        FillTasksArray(task_inProgress)
                        disable_actions = false
                        
                        DoTask(task_inProgress.type)
                        Wait(5000)
                        TasksRemaining = TasksRemaining - 1

                        if TasksRemaining == 0 then 
                            TriggerEvent('client:communityservice:finishService')
                            Notification("You have done all of your tasks! Your Finished!")
                        elseif TasksRemaining ~= 0 then 
                            Notification("You have: " .. TasksRemaining .. ' lasks left, Go find your next task!')
                            TriggerServerEvent('communityservice:updateTasks', TasksRemaining)
                        end
        
                        goto restart_thread
                    end
                end
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

RegisterNetEvent('client:communityservice:finishService')
AddEventHandler('client:communityservice:finishService', function()
    TasksRemaining = 0
    isInComserv = false
    TriggerServerEvent('communityservice:server:finishService')
end)

DoTask = function(type)
    if type == 'clean' then
        local hash = GetHashKey("prop_sponge_01")
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(100)
            RequestModel(hash)
        end
        local prop = CreateObject(hash, GetEntityCoords(PlayerPedId()), true, true, true)
        AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, -0.01, 90.0, 0.0, 0.0, true, true, false, false, 1, true)
        QBCore.Functions.Progressbar("clean_comserv", "Wiping down..", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = 'timetable@floyd@clean_kitchen@base',
            anim = 'base',
            flags = 49,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(), 'timetable@floyd@clean_kitchen@base', "base", 1.0)
            DeleteObject(prop)
        end, function() -- Cancel
            StopAnimTask(PlayerPedId(), 'timetable@floyd@clean_kitchen@base', "base", 1.0)
            DeleteObject(prop)
        end)         
    elseif type == 'cleanfront' then 

        local hash = GetHashKey("prop_sponge_01")
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(100)
            RequestModel(hash)
        end
        local prop = CreateObject(hash, GetEntityCoords(PlayerPedId()), true, true, true)
        AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, 0.0, 116.0, 8.0, 0.0, true, true, false, false, 1, true)
        QBCore.Functions.Progressbar("cleanfront_comserv", "Wiping down..", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = 'amb@world_human_maid_clean@',
            anim = 'idle_a',
            flags = 16,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(), 'amb@world_human_maid_clean@', "idle_a", 1.0)
            DeleteObject(prop)
        end, function() -- Cancel
            StopAnimTask(PlayerPedId(), 'amb@world_human_maid_clean@', "idle_a", 1.0)
            DeleteObject(prop)
        end) 
    elseif type == 'sweep' then
        local hash = GetHashKey("prop_tool_broom")
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(100)
            RequestModel(hash)
        end
        local prop = CreateObject(hash, GetEntityCoords(PlayerPedId()), true, true, true)
        AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), -0.005,0.0,0.0,360.0,360.0,0.0, true, true, false, false, 0, true)
        QBCore.Functions.Progressbar("sweep_comserv", "Wiping down..", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = 'amb@world_human_janitor@male@idle_a',
            anim = 'idle_a',
            flags = 49,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(), 'amb@world_human_janitor@male@idle_a', "idle_a", 1.0)
            DeleteObject(prop)

        end, function() -- Cancel
            StopAnimTask(PlayerPedId(), 'amb@world_human_janitor@male@idle_a', "idle_a", 1.0)
            DeleteObject(prop)
        end) 
    end

end

RemoveTask = function(action)
    local action_position = -1
    for i=1, #availableActions do
        if action.coords == availableActions[i].coords then
            action_position = i
        end
    end
    if action_position ~= -1 then
        table.remove(availableActions, action_position)
    end
end
  
DrawTask = function(x, y, z, text, color)
    if not text or not color or not x or not y or not z then return end
    local onScreen, gx, gy = GetScreenCoordFromWorldCoord(x, y, z)
    local dist = #(GetGameplayCamCoord() - vector3(x, y, z))
    
    local scale = ((1 / dist) * 2) * (1 / GetGameplayCamFov()) * 200
    if onScreen then
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringKeyboardDisplay(text)
        SetTextColour(color[1], color[2], color[3], 255)
        SetTextScale(0.0 * scale, 0.50 * scale)
        SetTextFont(0)
        SetTextCentre(1)
        SetTextDropshadow(1, 0, 0, 0, 155)
        EndTextCommandDisplayText(gx, gy)
        
        local height = GetTextScaleHeight(1 * scale, 0) - 0.005
        local length = string.len(text)
        local limiter = 120
        if length > 98 then
            length = 98
            limiter = 200
        end
        local width = length / limiter * scale
        DrawRect(gx, (gy + scale / 50), width, height, 0, 0, 0, 90)
    end
    
end


DrawAllAvailableTasks = function()
    for k,v in ipairs(availableActions) do
        DrawTask(v.coords.x, v.coords.y, v.coords.z, v.text, v.textColor)
    end
end

Notification = function(msg)
    QBCore.Functions.Notify(msg, 'primary', 5000)
end