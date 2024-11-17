local QBCore = exports['qb-core']:GetCoreObject()
local trackingVehicle = nil
local isTrackerActive = false
local trackerUses = 2

-- Function to place the GPS tracker on a vehicle
function PlaceTracker()
    local playerPed = PlayerPedId()
    local vehicle = GetVehicleInFront(playerPed)

    if DoesEntityExist(vehicle) then
        if trackerUses > 0 then
            trackingVehicle = vehicle
            isTrackerActive = true
            trackerUses = trackerUses - 1
            Notify("GPS Tracker", "Tracker placed on vehicle. Uses left: "
.. trackerUses, 'success')
            TrackVehicle()
        else
            Notify("GPS Tracker", "No more tracker uses left.", 'error')
        end
    else
        Notify("GPS Tracker", "No vehicle found in front of you.", 'error')
    end
end

-- Function to track the vehicle
function TrackVehicle()
    Citizen.CreateThread(function()
        while DoesEntityExist(trackingVehicle) and isTrackerActive do
            Citizen.Wait(5000) -- Report every 5 seconds
            local vehicleCoords = GetEntityCoords(trackingVehicle)
            local streetName, crossingRoad =
GetStreetNameAtCoord(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z)
            local direction = GetVehicleDirection(trackingVehicle)
            TriggerServerEvent('gps_tracker:reportLocation', streetName,
crossingRoad, direction)
        end
    end)
end

-- Function to notify the player
function Notify(title, message, type)
    exports['okokNotify']:Alert(title, message, 5000, type)
end

-- Register the item usage for Trojan USB
RegisterNetEvent('qb-gps_tracker:useTrojanUSB')
AddEventHandler('qb-gps_tracker:useTrojanUSB', function()
    if isTrackerActive then
        isTrackerActive = false
        Notify("GPS Tracker", "Tracker hacked and disabled.", 'success')
    else
        Notify("GPS Tracker", "No active tracker to hack.", 'error')
    end
end)

-- Function to disable the tracker when the vehicle is impounded or garaged
function DisableTrackerOnImpoundOrGarage(vehicle)
    if trackingVehicle == vehicle then
        isTrackerActive = false
        Notify("GPS Tracker", "Tracker disabled due to vehicle impound or
garage.", 'info')
    end
end

-- Event to handle vehicle impound
RegisterNetEvent('qb-vehiclekeys:impoundVehicle')
AddEventHandler('qb-vehiclekeys:impoundVehicle', function(vehicle)
    DisableTrackerOnImpoundOrGarage(vehicle)
end)

-- Event to handle vehicle garage
RegisterNetEvent('qb-garage:parkVehicle')
AddEventHandler('qb-garage:parkVehicle', function(vehicle)
    DisableTrackerOnImpoundOrGarage(vehicle)
end)

-- Function to get the vehicle in front of the player
function GetVehicleInFront(playerPed)
    local playerCoords = GetEntityCoords(playerPed)
    local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.0,
0.0)
    local rayHandle = StartShapeTestRay(playerCoords.x, playerCoords.y,
playerCoords.z, offset.x, offset.y, offset.z, 10, playerPed, 0)
    local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
    return vehicle
end

-- Function to get the vehicle direction
function GetVehicleDirection(vehicle)
    local heading = GetEntityHeading(vehicle)
    if heading >= 315 or heading < 45 then
        return "North"
    elseif heading >= 45 and heading < 135 then
        return "East"
    elseif heading >= 135 and heading < 225 then
        return "South"
    elseif heading >= 225 and heading < 315 then
        return "West"
    end
    return "Unknown"
end

-- Command to place the tracker
RegisterCommand('placetracker', function()
    local playerPed = PlayerPedId()
    local playerJob = QBCore.Functions.GetPlayerData().job.name

    if playerJob == 'leo' then
        PlaceTracker()
    else
        Notify("GPS Tracker", "You are not authorized to place a tracker.",
'error')
    end
end)
