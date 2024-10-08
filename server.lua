RegisterServerEvent('checkAdminPerms')
AddEventHandler('checkAdminPerms', function()
    
    if IsPlayerAceAllowed(source, "administrator") then
        TriggerClientEvent('openAdminMenu', source, true)
    end
end)
