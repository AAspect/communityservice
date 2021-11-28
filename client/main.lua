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
	{ type = "clean", coords = vector3(175.6, -986.0, 31.0), text = 'Dirty Wall, wipe it down!', textColor = {255, 255, 255} },
}
  
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

                        TasksRemaining = TasksRemaining - 1

                        if TasksRemaining == 0 then 
                            TriggerServerEvent('communityservice:server:finishService')
                        elseif TasksRemaining ~= 0 then 
                            Notification("You have: " .. TasksRemaining .. ' lasks left')
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
  
DrawScene = function(x, y, z, text, color)
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
        DrawScene(v.coords.x, v.coords.y, v.coords.z, v.text, v.textColor)
    end
end

Notification = function(msg)
    QBCore.Functions.Notify(msg, 'primary', 5000)
end