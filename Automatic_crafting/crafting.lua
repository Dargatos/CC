local me = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")
local chest = peripheral.find("minecraft:chest")
local diskdrive = peripheral.find("drive")

--List of all items that get crafted automatically
meItemList = { 
    [1] = {name = "SteelIngots", id = "mekanism:ingot_steel", amount = 5000},
    [2] = {name = "Atomic Alloy", id = "mekanism:alloy_atomic", amount = 1000},
    [3] = {name = "inductionCell", id = "mekanism:ultimate_induction_cell",amount = 5},
    [4] = {name = "Spruce Planks", id = "minecraft:spruce_planks", amount = 1024}
}

-- adds or removes items from the list above
function ToList(chestItemName,chestItemId,chestItemAmount,action)
    if not action then
        return
    end

    newitem = {name = chestItemName,id = chestItemId,amount = chestItemAmount}

    if action == "add" then
        table.insert(meItemList, newitem)

    elseif action == "remove" then
        --removes item form List
        for i, item in pairs(meItemList) do
            if item.id == chestItemId then
                table.remove(meItemList, i)
                break
            end
        end
    end
end

-- checks the item and retuns all important values
local function checkItems(itemID)
    local meItem = me.getItem({name = itemID})
    local itemAmount = 0
    local isCrafting = me.isItemCrafting({name = itemID})

    if not meItem then
        printError("No such Item exists check spelling " ,itemID)
        return 0, false, "wrongID"
    end

    if meItem.amount then
        itemAmount = meItem.amount
    end

    local craftable = me.isItemCraftable({name = itemID})

    return itemAmount, isCrafting , craftable
end

local function craftItems(ItemID, value)
    ItemToCraft = {name = ItemID,count = value}
    crafting, err = me.craftItem(ItemToCraft)
    return crafting, err
end

local function calcToCraft(stocked, desired)
    local missing = desired - stocked
    return missing
end

local function printlist()
    print("Items in list currently are :")
    for i, item in ipairs(meItemList) do
        print(item.name, item.id, item.amount)
    end
end

local function readChest()
    local chestTable = chest.list()
    if chestTable[1] then
        local input = read()

        if input == "list" then
            printlist()
        elseif input == "save" then
            saveListtoDrive()
        end


        for slot, item in pairs(chestTable) do
            
            local slotitem = item.name
            local itemcount = 2 ^ item.count
            local name = item.name:match("([^:]+)$")

            local check = checkIfAlreadyInList(slotitem)

            if check == true and input == "remove" then
                print("removing: " .. slotitem)
                ToList(name,slotitem,itemcount,input)
            elseif check == false and input == "add" then
                print("adding: " .. slotitem)
                ToList(name,slotitem,itemcount,input)
            end
        end
    end
end

function checkIfAlreadyInList(id)
    for i, part in ipairs(meItemList) do
        if id == part.id then
            print("Item already in Me")
            return true
        end
    end
    return false
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

local function prepareMonitor()
    monitor.clear()
    monitor.setTextScale(1)
    --monx, mony = monitor.getSize()

end

function saveListtoDrive()
    print("Started saving to Disk")
    print(diskdrive.isDiskPresent())
    if not diskdrive.isDiskPresent() then
        printError("no disk check your diskdrive")
        return
    end
    local seriTable = textutils.serialize(meItemList)
    local diskPath = diskdrive.getMountPath(diskdrive)
    local filePath = diskPath .. "/autocraftingslist.txt"
    local file = fs.open(filePath, "w")

    if file then
        file.write(seriTable)
        file.close()
        print("List saved to " .. filePath)
    end
    
end

local function main()
    printlist()
    print(" ")
    term.setTextColor(colors.blue)
    print("Put Items in chest and type add or remove to edit list")
    term.setTextColor(colors.white)
    -- Main loop of cheking items and crafting if necessary
    while true do
        readChest()
        getinfo()
        sleep(1)
    end
end

main()