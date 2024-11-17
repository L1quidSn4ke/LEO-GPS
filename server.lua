
local QBCore = exports['qb-core']:GetCoreObject()

-- Event to report the location of the tracked vehicle
RegisterServerEvent('gps_tracker:reportLocation')
AddEventHandler('gps_tracker:reportLocation', function(streetName,
crossingRoad, direction)
    local source = source

    -- Broadcast the location to all LEO players
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = QBCore.Functions.GetPlayer(playerId)
        if xPlayer and xPlayer.PlayerData.job.name == 'leo' then
            TriggerClientEvent('okokNotify:Alert', playerId, "GPS Tracker",
"Vehicle located at: " .. streetName .. " and " .. crossingRoad .. ",
traveling " .. direction, 5000, 'success')
        end
    end
end)

-- Handle item usage events
QBCore.Functions.CreateUseableItem("trojan_usb", function(source, item)
    TriggerClientEvent('qb-gps_tracker:useTrojanUSB', source)
end)
