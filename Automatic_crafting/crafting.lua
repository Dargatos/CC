local me = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")
local chest = peripheral.find("minecraft:chest")



meItemList = {
    [1] = {name = "SteelIngots", id = "mekanism:ingot_steel", amount = 5000},
    [2] = {name = "Atomic Alloy", id = "mekanism:alloy_atomic", amount = 1000},
    [3] = {name = "inductionCell", id = "mekanism:ultimate_induction_cell",amount = 5},
    [4] = {name = "Spruce Planks", id = "minecraft:spruce_planks", amount = 1024}
}

function addToList(chestItemName,chestItemId,chestItemAmount)
    if not chestItemAmount then
        amount = 5000
    end
    newitem = {name = chestItemName,id = chestItemId,amount = chestItemAmount}

    table.insert(meItemList, newitem)
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

local function printlist()
    for i, item in ipairs(meItemList) do
        print(item.name, item.id, item.amount)
    end
end

local function readChest()
    local chestTable = chest.list()
    print(chestTable[1]) 
    if chestTable[1] then
        input = read()
        if input == "list" then
            printlist()
        end
        for slot, item in pairs(chestTable) do
            local slotitem = item.name
            local itemcount = 2 ^ item.count
            local name = item.name:match("([^:]+)$")

            print(slotitem)
            

            local check = checkIfAlreadyInList(slotitem)
            if check == true then
                print(name,slotitem,itemcount)
                addToList(name,slotitem,itemcount)
            end
        end
    end
end

function checkIfAlreadyInList(id)
    for i, part in ipairs(meItemList) do
        if id == part.id then
            return false
        end
    end
    return true
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
        readChest()
        getinfo()
        sleep(5)
    end
end

main()