
ESX = nil
local isNoClipping = false
local isGodMode = false
local showNametags = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if IsControlJustReleased(0, 168) then
            TriggerServerEvent('checkAdminPerms')
        end
    end
end)
            
RegisterNetEvent('openAdminMenu')
AddEventHandler('openAdminMenu', function(hasPerms)
    if hasPerms then
        OpenAdminMenu()
    end
end)
       
        

-- Other Keys That may be Important
-- F6 = 167
-- F3 = 170
-- F1 = 288
-- F2 = 289
-- F7 = 168
-- F9 = 56

function OpenAdminMenu()
    local elements = {
        {label = "Self", value = "self_options"},
        {label = "Vehicle Options", value = "vehicle_options"},
        {label = "Player Options", value = "player_options"}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'admin_menu', {
        title = 'Admin Menu',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'self_options' then
            OpenSelfOptionsMenu()
        elseif data.current.value == 'vehicle_options' then
            OpenVehicleOptionsMenu()
        elseif data.current.value == 'player_options' then
            OpenPlayerOptionsMenu()
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenSelfOptionsMenu()
    local elements = {
        {label = (isNoClipping and "[x] NoClip" or "[ ] NoClip"), value = "noclip"},
        {label = (isGodMode and "[x] Godmode" or "[ ] Godmode"), value = "godmode"},
        {label = (showNametags and "[x] Nametags" or "[ ] Nametags"), value = "nametags"},
        {label = "Heal", value = "heal"}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'self_options_menu', {
        title = 'Self Options',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'noclip' then
            ToggleNoClip()
        elseif data.current.value == 'godmode' then
            ToggleGodmode()
        elseif data.current.value == 'nametags' then
            ToggleNametags()
        elseif data.current.value == 'heal' then
            HealPlayer()
        end
        menu.close()
        OpenSelfOptionsMenu() -- Update the menu
    end, function(data, menu)
        menu.close()
    end)
end

function ToggleNoClip()
    isNoClipping = not isNoClipping
    local playerPed = PlayerPedId()

    if isNoClipping then
        SetEntityInvincible(playerPed, true)
        SetEntityVisible(playerPed, false, false)
        ESX.ShowNotification("NoClip activated.")
    else
        SetEntityInvincible(playerPed, isGodMode) -- Godmode only if activated
        SetEntityVisible(playerPed, true, true)
        ESX.ShowNotification("NoClip deactivated.")
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isNoClipping then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed, false)
            local forward = GetEntityForwardVector(playerPed)
            local right = vector3(forward.y, -forward.x, 0.0)
            local up = vector3(0.0, 0.0, 1.0)

            if IsControlPressed(0, 32) then coords = coords + forward end -- W
            if IsControlPressed(0, 33) then coords = coords - forward end -- S
            if IsControlPressed(0, 34) then coords = coords - right end -- A
            if IsControlPressed(0, 35) then coords = coords + right end -- D
            if IsControlPressed(0, 44) then coords = coords - up end -- Q
            if IsControlPressed(0, 38) then coords = coords + up end -- E

            SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z, true, true, true)
        end
    end
end)

function ToggleGodmode()
    isGodMode = not isGodMode
    local playerPed = PlayerPedId()

    SetEntityInvincible(playerPed, isGodMode)
    ESX.ShowNotification(isGodMode and "Godmode activated." or "Godmode deactivated.")
end

function ToggleNametags()
    showNametags = not showNametags
    ESX.ShowNotification(showNametags and "Nametags activated." or "Nametags deactivated.")
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if showNametags then
            for _, player in ipairs(GetActivePlayers()) do
                local playerPed = GetPlayerPed(player)
                local playerCoords = GetEntityCoords(playerPed)
                local playerId = GetPlayerServerId(player)
                local playerName = GetPlayerName(player)

                DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 1.0, '['..playerId..'] '..playerName)
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function HealPlayer()
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, 200) 
    SetPedArmour(playerPed, 100) 
    ESX.ShowNotification("You have been healed (Health & Armor).")
end

function OpenVehicleOptionsMenu()
    local elements = {
        {label = "Spawn Vehicle", value = "spawn_vehicle"},
        {label = "Delete Vehicle", value = "delete_vehicle"},
        {label = "Repair Vehicle", value = "repair_vehicle"}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_options_menu', {
        title = 'Vehicle Options',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'spawn_vehicle' then
            SpawnVehicleInput()
        elseif data.current.value == 'delete_vehicle' then
            DeleteVehicle()
        elseif data.current.value == 'repair_vehicle' then
            RepairVehicle()
        end
    end, function(data, menu)
        menu.close()
    end)
end

function SpawnVehicleInput()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'vehicle_spawn_input', {
        title = 'Enter Vehicle Name'
    }, function(data, menu)
        local vehicleName = string.lower(data.value)

        if vehicleName and vehicleName ~= "" then 
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            ESX.Game.SpawnVehicle(vehicleName, coords, GetEntityHeading(playerPed), function(vehicle)
                if vehicle then
                    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                    ESX.ShowNotification("Vehicle " .. vehicleName .. " spawned.")
                else
                    ESX.ShowNotification("Invalid vehicle name or vehicle could not be spawned.")
                end
            end)
        else
            ESX.ShowNotification("Invalid vehicle name.")
        end
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function DeleteVehicle()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle and vehicle ~= 0 then
        ESX.Game.DeleteVehicle(vehicle)
        ESX.ShowNotification("Vehicle deleted.")
    else
        ESX.ShowNotification("You are not in a vehicle.")
    end
end

function RepairVehicle()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle and vehicle ~= 0 then
        SetVehicleFixed(vehicle)
        SetVehicleDirtLevel(vehicle, 0)
        ESX.ShowNotification("Vehicle repaired.")
    else
        ESX.ShowNotification("You are not in a vehicle.")
    end
end

function OpenPlayerOptionsMenu()
    local players = {}
    local searchText = ""

  
    for _, player in ipairs(GetActivePlayers()) do
        local playerPed = GetPlayerPed(player)
        local playerId = GetPlayerServerId(player)
        local playerName = GetPlayerName(player)

        table.insert(players, {id = playerId, name = playerName})
    end

   
    local function FilterPlayers()
        local filtered = {}
        for _, player in ipairs(players) do
            if string.match(player.name:lower(), searchText:lower()) then
                table.insert(filtered, player)
            end
        end
        return filtered
    end

    
    local function ShowPlayerOptionsMenu()
        local elements = {}

        for _, player in ipairs(FilterPlayers()) do
            table.insert(elements, {label = player.name .. ' [' .. player.id .. ']', value = player.id})
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_options_menu', {
            title = 'Player Options',
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            local playerId = data.current.value
            local actionElements = {
                {label = "Bring", value = "bring"},
                {label = "Go To", value = "go_to"}
            }

            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_action_menu', {
                title = 'Actions for ' .. data.current.label,
                align = 'top-left',
                elements = actionElements
            }, function(actionData, actionMenu)
                if actionData.current.value == 'bring' then
                    BringPlayer(playerId)
                elseif actionData.current.value == 'go_to' then
                    GoToPlayer(playerId)
                elseif actionData.current.value == 'spectate' then
                    SpectatePlayer(playerId)
                end
                actionMenu.close()
            end, function(actionData, actionMenu)
                actionMenu.close()
            end)
        end, function(data, menu)
            menu.close()
        end)
    end


    ShowPlayerOptionsMenu()
end


function BringPlayer(playerId)
    local playerPed = GetPlayerPed(GetPlayerFromServerId(playerId))
    local coords = GetEntityCoords(PlayerPedId())
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z)
    ESX.ShowNotification("You brought " .. playerId)
end


function GoToPlayer(playerId)
    local playerPed = GetPlayerPed(GetPlayerFromServerId(playerId))
    local coords = GetEntityCoords(playerPed)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
    ESX.ShowNotification("You went to " .. playerId)
end

