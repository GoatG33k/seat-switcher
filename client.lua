-- optimizations
local tonumber            = tonumber
local unpack              = table.unpack
local CreateThread        = Citizen.CreateThread
local Wait                = Citizen.Wait
local TriggerEvent        = TriggerEvent
local RegisterCommand     = RegisterCommand
local PlayerPedId         = PlayerPedId
local IsPedInAnyVehicle   = IsPedInAnyVehicle
local GetPedInVehicleSeat = GetPedInVehicleSeat
local GetVehiclePedIsIn   = GetVehiclePedIsIn
local GetIsTaskActive     = GetIsTaskActive
local SetPedIntoVehicle   = SetPedIntoVehicle
local disabled            = false

CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) and not disabled then
            local veh = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(veh, 0) == ped then
                if not GetIsTaskActive(ped, 164) and GetIsTaskActive(ped, 165) then
                    SetPedIntoVehicle(PlayerPedId(), veh, 0)
                end
            end
        end
    end
end)

RegisterCommand("seat", function(_, args)
    local seatIndex = unpack(args)
    seatIndex       = tonumber(seatIndex) - 1

    if seatIndex < -1 or seatIndex >= 4 then
        SetNotificationTextEntry('STRING')
        AddTextComponentString("~r~Seat ~b~" .. (seatIndex + 1) .. "~r~ is not recognized")
        DrawNotification(true, true)
    else
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)

        if veh ~= nil and veh > 0 then
            CreateThread(function()
                disabled = true
                SetPedIntoVehicle(PlayerPedId(), veh, seatIndex)
                Wait(50)
                disabled = false
            end)
        end
    end
end)

RegisterCommand("shuff", function()
    CreateThread(function()
        disabled = true
        Wait(3000)
        disabled = false
    end)
end)

TriggerEvent('chat:addSuggestion', '/shuff', 'Temporarily disable seat switching protection')
TriggerEvent('chat:addSuggestion', '/seat', 'Switch seats in the current vehicle',
             { { name = 'seat', help = "Switch seats in the current vehicle. 0 = driver, 1 = passenger, 2-3 = back seats" } })
