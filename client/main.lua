local QBCore = exports['qb-core']:GetCoreObject()

local hascompservleft = false
RegisterNetEvent('communityservice:setplayerincomserv')
AddEventHandler('communityservice:setplayerincomserv', function(amount_tasks)


    if hascompservleft ~= true then 
        StartService(amount_tasks)
    else 
        print('this player has community service already!')
    end
end)
local tasksLeft = nil
local availibleTasks = {}


local taskTable = {
    { id = 'dirtywall1', description = "cleaningdirtywall", text = 'Dirt Wall', textColor = {139,69,19}, task = 'clean', coords = vector3(181.5283, -941.976, 30.5967) },
    { id = 'dirtywall2', description = "cleaningdirtywall", text = 'Dirty Wall', textColor = {139,69,19}, task = 'clean', coords = vector3(193.0, -957.3, 31.1) },
    { id = 'dirtywall3', description = "cleaningdirtywall", text = 'Dirty Wall', textColor = {139,69,19}, task = 'clean', coords = vector3(199.6, -951.1, 30.4) },
    { id = 'dirtywall4', description = "cleaningdirtywall", text = 'Dirty Wall', textColor = {139,69,19}, task = 'clean', coords = vector3(205.4, -996.1, 29.7) },
    { id = 'dirtywall5', description = "cleaningdirtywall", text = 'Dirty Wall', textColor = {139,69,19}, task = 'clean', coords = vector3(149.5, -954.9, 30.6) },
    { id = 'dirtywall6', description = "cleaningdirtywall", text = 'Dirty Wall', textColor = {139,69,19}, task = 'clean', coords = vector3(156.3, -944.8, 30.2) },





} 



function StartService(amount_tasks)
    hascompservleft = true
    AddTasksToTable()
    tasksLeft = amount_tasks
end



function AddTasksToTable()
    for k, v in ipairs(taskTable) do
        table.insert(availibleTasks, v)
    end
end

function DoTask(taskid)
    for i = 1, #taskTable do
        local value = taskTable[i]
        if value.id == taskid then
            table.remove(availibleTasks, i)
            tasksLeft = tasksLeft - 1
            if tasksLeft == 0 then 
                EndService()
            end
        end
    end
end

RegisterCommand('stopservice', function()
    EndService()    
end)

RegisterCommand('test2', function()
    print(json.encode(availibleTasks))
end)

function EndService()
    hascompservleft = false
    print('you have no more community service left!')
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


local legion_square = PolyZone:Create({
    vector2(212.05163574219, -1027.6115722656),
    vector2(269.73852539062, -868.36657714844),
    vector2(186.45692443848, -837.44067382812),
    vector2(180.47364807129, -836.68640136719),
    vector2(124.11971282959, -989.26965332031),
    vector2(122.27320861816, -995.49749755859)
  }, {
    name="legion_square",
    --minZ = 28.949378967285,
    --maxZ = 31.263444900513
  })
  
  
legion_square:onPlayerInOut(function(isPointInside)
    if isPointInside and hascompservleft then
        while hascompservleft do
            Wait(0)
            for k, v in ipairs(availibleTasks) do
                plycoords = GetEntityCoords(PlayerPedId())
                local dist = #(plycoords - v.coords)
    
    
                if dist <= 15.0 then
                    DrawScene(v.coords['x'],v.coords['y'],v.coords['z'], 'test', v.textColor)
                    if dist <= 2.0 then
                        if IsControlJustPressed(0, 38) then 
                            DoTask(v.id)
                        end 
                    end
                end
            end
    
        end
    elseif hascompservleft and not isPointInside then 
        print('adding service, dont leave :)')
    end

end)