local function item_stats(item_name)
    local it_name = item_name
    local me = peripheral.find("meBridge")
    local items = me.listItems()

    for _, item in pairs(items) do 
        if item.name == it_name then
            return item
        end
    end
    return 0
end