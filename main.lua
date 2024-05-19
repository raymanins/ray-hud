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

-- Function to update HUD values
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

        -- Show the minimap and hide default health/armor
        DisplayRadar(true)
        DisplayHud(false)
    else
        HUD.speed = 0
        HUD.fuel = 0
        HUD.seatbelt = false
        
        -- Hide the minimap and show default health/armor
        DisplayRadar(false)
        DisplayHud(true)
    end

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

-- Ensure HUD is hidden initially and only shown when player is loaded
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Explicitly set HUD to be hidden
        HUD.enabled = false
        SendNUIMessage({
            action = "show_hud",
            enabled = HUD.enabled
        })
        print("Resource started, hiding HUD")

        -- Initially hide minimap
        DisplayRadar(false)
        DisplayHud(true)
    end
end)

-- Handle resource stop to hide the HUD
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        HUD.enabled = false
        SendNUIMessage({
            action = "show_hud",
            enabled = HUD.enabled
        })
        print("Resource stopped, hiding HUD")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(33) -- Update speed roughly every 33 milliseconds for 30fps smoothness
        updateHUD()
    end
end)

RegisterCommand('togglehud', function()
    HUD.enabled = not HUD.enabled
    SendNUIMessage({
        action = "toggle_hud",
        enabled = HUD.enabled
    })
    print("Toggled HUD, new state: " .. tostring(HUD.enabled))
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    HUD.enabled = true
    SendNUIMessage({
        action = "show_hud",
        enabled = HUD.enabled
    })
    print("Player loaded, showing HUD")
    updateHUD() -- Update HUD values when player is loaded
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    HUD.enabled = false
    SendNUIMessage({
        action = "show_hud",
        enabled = HUD.enabled
    })
    print("Player unloaded, hiding HUD")
end)
