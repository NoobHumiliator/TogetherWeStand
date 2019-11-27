function RemoveRapier(keys)
    local caster = keys.caster
    local ability = keys.ability
    for i = 0, 5, 1 do
        local current_item = caster:GetItemInSlot(i)
        if current_item ~= nil then
            if string.find(current_item:GetName(), "item_rapier") then
                caster:RemoveItem(current_item)
            end
        end
    end
end