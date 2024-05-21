local QBCore = exports['qb-core']:GetCoreObject()

local HUD = {
    enabled = false,
    health = 100,
    armor = 100,
    food = 100,
    water = 100,
    speed = 0,
    fuel = 100,
    seatbelt = false
}

local function updateHUD()
    if not HUD.enabled then return end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    local playerData = QBCore.Functions.GetPlayerData()
    if not playerData or not playerData.metadata then
        return
    end

    HUD.health = math.floor(GetEntityHealth(ped) - 100)
    HUD.armor = math.floor(GetPedArmour(ped))
    HUD.food = math.floor(playerData.metadata["hunger"])
    HUD.water = math.floor(playerData.metadata["thirst"])

    if IsPedInAnyVehicle(ped, false) then
        HUD.speed = math.floor(GetEntitySpeed(vehicle) * 3.6) -- Speed in km/h
        HUD.fuel = math.floor(GetVehicleFuelLevel(vehicle))
        HUD.seatbelt = LocalPlayer.state.seatbelt

        -- Show the minimap when in a vehicle
        DisplayRadar(true)
    else
        HUD.speed = 0
        HUD.fuel = 0
        HUD.seatbelt = false

        -- Hide the minimap when not in a vehicle
        DisplayRadar(false)
    end

    print("Sending NUI Message with updated HUD values") -- Debug print
    SendNUIMessage({
        action = "update_hud",
        health = HUD.health,
        armor = HUD.armor,
        food = HUD.food,
        water = HUD.water,
        speed = HUD.speed,
        fuel = HUD.fuel,
        seatbelt = HUD.seatbelt
    })
end

-- Event listeners for food and water updates
RegisterNetEvent('hud:updateFood', function(value)
    HUD.food = value
    print("Food updated to: " .. value) -- Debug print
    updateHUD()
end)

RegisterNetEvent('hud:updateWater', function(value)
    HUD.water = value
    print("Water updated to: " .. value) -- Debug print
    updateHUD()
end)

-- Ensure HUD is hidden initially and only shown when player is loaded
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        HUD.enabled = false
        SendNUIMessage({
            action = "show_hud",
            enabled = HUD.enabled
        })
        DisplayRadar(false)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        HUD.enabled = false
        SendNUIMessage({
            action = "show_hud",
            enabled = HUD.enabled
        })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(33)
        updateHUD()
    end
end)

RegisterCommand('togglehud', function()
    HUD.enabled = not HUD.enabled
    SendNUIMessage({
        action = "toggle_hud",
        enabled = HUD.enabled
    })
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    HUD.enabled = true
    SendNUIMessage({
        action = "show_hud",
        enabled = HUD.enabled
    })
    updateHUD()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    HUD.enabled = false
    SendNUIMessage({
        action = "show_hud",
        enabled = HUD.enabled
    })
end)

AddEventHandler('playerSpawned', function()
    DisplayRadar(false)
end)

AddEventHandler('onClientMapStart', function()
    DisplayRadar(false)
end)
