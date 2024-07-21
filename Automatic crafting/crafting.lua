local me = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")



meItemList = {
    [1] = {name = "SteelIngots", id = "mekanism:ingot_steel", amount = 5000},
    [2] = {name = "Atomic Alloy", id = "mekanism:alloy_atomic", amount = 1000},
    [3] = {name = "inductionCell", id = "mekanism:ultimate_induction_cell",amount = 5},
    [4] = {name = "Spruce Planks", id = "minecraft:spruce_planks", amount = 1024}
}

function addToList(name,id,amount)
    if not amount then
        amount = 5000
    end
    newitem = {name = name,id = id,amount = amount}
    meItemList.insert(newitem)
end

local function checkItems(itemID)
    local meItem = me.getItem({name = itemID})
    local itemAmount
    local isCrafting
    if not meItem then
        printError("No such Item exists check spelling " ,itemID)
        return 0, false, "wrongID"
    end

    if not meItem.amount then
        itemAmount = 0

    else
        itemAmount = meItem.amount
    end

    if me.isItemCrafting({name = itemID}) then
        isCrafting = true
    else
        isCrafting = false
    end

    local craftable = me.isItemCraftable({name = itemID})

    return itemAmount, isCrafting , craftable
end

local function craftItems(ItemID, value)
    ItemToCraft = {name = ItemID,count = value}
    crafting, err = me.craftItem(ItemToCraft)
    print (err)
    return crafting, err
end

local function calcToCraft(stocked, desired)
    local missing = desired - stocked
    return missing
end

local function getinfo()
    for i, item in ipairs(meItemList)do

        local name = item.name
        local id = item.id
        local amount = item.amount
        local craftable
        local toCraft

        stockedItems, isCrafting, craftable = checkItems(id)
        toCraft = calcToCraft(stockedItems,amount)
        
        if not craftable then 
            printError(name .. " is not Craftable")
        elseif not isCrafting and toCraft > 0 then
            -- Start a crating Job
            
            getscrafted, craftingError = craftItems(id,toCraft)
            
            if getscrafted then
                print("Started crafting some tasty " .. name .. " " .. toCraft .. " pieces")
            else
                printError("Crafting Error: ".. name .. " " .. craftingError)
            end
        end
        
    end

end

local function main()

    -- Main loop of cheking items and crafting if necessary
    while true do
        getinfo()
        sleep(5)
    end
end

main()