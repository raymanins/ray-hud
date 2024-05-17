local QBCore = exports['qb-core']:GetCoreObject()

local HUD = {
    enabled = true,
    health = 100,
    armor = 100,
    food = 100,
    water = 100,
    speed = 0,
    fuel = 100,
    seatbelt = false
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(33) -- Update speed roughly every 33 milliseconds for 30fps smoothness
        if HUD.enabled then
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            HUD.health = math.floor(GetEntityHealth(ped) - 100)
            HUD.armor = math.floor(GetPedArmour(ped))
            HUD.food = math.floor(QBCore.Functions.GetPlayerData().metadata["hunger"])
            HUD.water = math.floor(QBCore.Functions.GetPlayerData().metadata["thirst"])

            if IsPedInAnyVehicle(ped) then
                HUD.speed = math.floor(GetEntitySpeed(vehicle) * 3.6) -- Speed in km/h
                HUD.fuel = math.floor(GetVehicleFuelLevel(vehicle))
                HUD.seatbelt = LocalPlayer.state.seatbelt
            else
                HUD.speed = 0
                HUD.fuel = 0
                HUD.seatbelt = false
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
    end
end)



RegisterCommand('togglehud', function()
    HUD.enabled = not HUD.enabled
    SendNUIMessage({
        action = "toggle_hud",
        enabled = HUD.enabled
    })
end)
