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
    { id = 'dirtywall1', description = "cleaningdirtywall", text = 'Dirty Wall', textColor = {139,69,19}, task = 'clean', coords = vector3(181.5, -941.9, 30.5) },
    { id = 'dirtywall2', description = "cleaningdirtywall", text = 'Dirty Wall', textColor = {139,69,19}, task = 'clean', coords = vector3(193.0, -957.3, 31.1) },
    { id = 'dirtywall3', description = "cleaningdirtywall", text = 'Dirty Wall', textColor = {139,69,19}, task = 'clean', coords = vector3(199.6, -951.1, 30.4) },
    { id = 'dirtywall4', description = "cleaningdirtywall", text = 'Dirty Wall', textColor = {139,69,19}, task = 'clean', coords = vector3(205.4, -996.1, 29.7) },
    { id = 'dirtywall5', description = "cleaningdirtywall", text = 'Dirty Wall', textColor = {139,69,19}, task = 'clean', coords = vector3(149.5, -954.9, 30.6) },
    { id = 'dirtywall6', description = "cleaningdirtywall", text = 'Dirty Wall', textColor = {139,69,19}, task = 'clean', coords = vector3(156.3, -944.8, 30.2) },


    { id = 'dirtyfloor1', description = "cleaningdirtyfloor", text = 'Dirty Floor', textColor = {139,69,19}, task = 'clean', coords = vector3(188.1, -924.6, 30.0) },



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
            for k, v in ipairs(taskTable) do
                if v.id == taskid then
                    Wait(1000)
                    table.insert(availibleTasks, v)
                end
            end
            tasksLeft = tasksLeft - 1
            if tasksLeft == 0 then 
                EndService()
            end
        end
    end
end

function EndService()
    hascompservleft = false
    print('you have no more community service left!')
end

local function DrawText3D(x, y, z, text, color)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    if onScreen then 
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(color[1], color[2], color[3], 215)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        SetDrawOrigin(x,y,z, 0)
        SetTextDropshadow(1, 0, 0, 0, 255)
        DrawText(0.0, 0.0)
        local factor = (string.len(text)) / 370
        DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
        ClearDrawOrigin()
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
                    DrawText3D(v.coords['x'],v.coords['y'],v.coords['z'], v.text, v.textColor)
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

