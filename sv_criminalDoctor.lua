ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

RegisterServerEvent("chip_cDoc:takeMoney")
AddEventHandler("chip_cDoc:takeMoney", function()
    local _source = source
    local xPlayer  = ESX.GetPlayerFromId(_source)
    if xPlayer.getMoney() > Config.toPay then
        print("Hello1")
        TriggerClientEvent("chip_cDoc:getHelp", source)
        xPlayer.removeMoney(2000)
    else
        print("I aint got no dollas")
        TriggerClientEvent('mythic_notify:client:SendAlert', source, 
        { 
            type = 'error', 
            text = 'You dont have enough money', 
            style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } 
        })
    end

end)