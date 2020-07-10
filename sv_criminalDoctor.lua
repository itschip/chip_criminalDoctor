ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

RegisterServerEvent("chip_cDoc:takeMoney")
AddEventHandler("chip_cDoc:takeMoney", function()
    local _source = source
    local xPlayer  = ESX.GetPlayerFromId(_source)
    if xPlayer.getMoney() > Config.toPay then
        TriggerClientEvent("chip_cDoc:getHelp", source)
        xPlayer.removeMoney(Config.toPay)
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, 
        { 
            type = 'error', 
            text = 'You dont have enough money', 
            style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } 
        })
    end

end)