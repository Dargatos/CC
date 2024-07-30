-- Adding peripherals
local monitor = peripheral.find("monitor")
local me = peripheral.find("meBridge")
local screen = "Stats"

-- Declaring tables
local chosenItems = {
    "minecraft:wheat",
    "minecraft:cobblestone",
    "mekanism:dust_sulfur",
    "minecraft:diamond",
    "minecraft:iron_ingot", 
    "minecraft:redstone",
    "minecraft:gold_ingot",
    "malum:wicked_spirit",
    "malum:arcane_spirit",
    "malum:aerial_spirit",
    "malum:earthen_spirit",
    "malum:eldritch_spirit",
    "mekanism:sodium"
}
meStats = {}
maxData = 700
local function savetData(meitem)
    -- Checks if there is already a table
    local noTable = true
    if #meStats == 0 then 
        noTable = true 
    end
    for i, item in pairs(meStats) do
        if item.name == meitem.name then
            noTable = false
            break
        end
    end

    -- if there is no table create and stores the new one
    if noTable == true then

        table.insert(meStats,{name = meitem.name,stats = {}})
    end

    -- Saves the data in the table
    for i, entry  in pairs(meStats) do
        if entry.name == meitem.name then
            local amount = meitem.amount or 0
            table.insert(entry.stats,1 ,amount)
        end
    end    
end

local function storeMeStats()
    while true do
        local melist = {}

        -- Sometimes Me doesnt return any data so thats for the case it does that
        while true do
            melist = me.listItems()
            if melist then
                break
            end
            printError("me didnt return values")
            sleep(1)
        end

        for i, item in pairs(melist) do
            savetData(item)
        end

        if #meStats > maxData then
            table.remove(meStats,1)
        end
        print("Stats Saved")
        sleep(1)
    end
end

local function read_system_values()
    local items

    while true do
        items = me.listItems()
        if items then
            
            break
        end
        print("me didnt retun values")
        sleep(1)
    end

    -- Searching for items in "list" and storing value in array
    for _, item_name in ipairs(list) do
        for _, item in pairs(items) do
            if item.name == item_name then
                add_amount_values(item_name, item.amount)
                
            end
            
        end
        
    end
    return true
end

-- Im bad at remembering so for my brain some copys fo string functions
-- sixhundred_sec = string.format("%.2f/h", sixhundred_sec)  -- Round to 2 decimal places
-- sixty_sec = string.format("%.0f/m", sixty_sec)  -- Round to 2 decimal places
-- ten_sec = string.format("%.2f/s", ten_sec)  -- Round to 2 decimal places

local function formatWithDots(number)
    -- Convert the number to a string
    local numStr = tostring(number)

    -- Reverse the string to process from the end
    local reversed = string.reverse(numStr)

    -- Insert dots every three characters
    local withDots = reversed:gsub("(%d%d%d)", "%1.")

    -- Reverse the string back and remove any leading dot
    withDots = string.reverse(withDots):gsub("^% ", "")

    return withDots
end

local function display_on_monitor()
    monitor.clear()
    monitor.setTextScale(1)
    monitor.setCursorPos(1,1)
    monitor.setTextColor(1)
    monitor.write("Items:")
    monitor.setCursorPos(19,1)
    monitor.write("Stored:")
    monitor.setCursorPos(39,1)
    monitor.write("Increase every:")

    for i, item in ipairs(table_list) do
        monitor.setTextColor(1)
        monitor.setCursorPos(1, i+2)
        local last_value = item.children[#item.children] or 0
        local _, _, itemName = string.find(item.name, ":(.*)")

        monitor.write(itemName)
        monitor.setCursorPos(18,i+2)
        monitor.write(formatWithDots(last_value))
        print(last_value)

        local differences = clac_diff(item.name)
        local j = 0
        monitor.setCursorPos(33,2)
        monitor.write("10 sec       1min       10min")

        -- Creating the 3 diffrence Increase lists I
        for j , time_span in ipairs (differences) do
            monitor.setCursorPos(20 + (j * 12),i + 2)
            if string.sub(time_span, 1, 1) == "-" then --If its a negative
                monitor.setTextColor(16384) --Red
            elseif time_span == "Wait" then
                monitor.write("  ")
                monitor.setTextColor(256) -- Gray 
            else
                monitor.write(" ")
                if string.sub(time_span, 1, 4) == "0.00" or string.sub(time_span, 1, 3) == "0/m" then --If its not a number
                    monitor.setTextColor(1) --White
                else
                    monitor.setTextColor(8192) -- Green
                end
            end
            monitor.write(time_span)
            monitor.setTextColor(1)
        end

    end
end

local function getIndexofItem(choosen)
    for i, meItem in pairs(meStats) do
        if choosen == meItem.name then
            return i
        end
    end
    return false
end

local function drawItemData(x,y,textcolor,switch,bg1,bg2,displayIncrease,choosenitem,storedOffst,increaseOffset)
    local storedOffset = storedOffset or 19
    local increaseOffset = increaseOffset or 11
    local increaseOffset = increaseOffset + storedOffset
    monitor.setCursorPos(x,y)
    monitor.setTextColor(textcolor)

    if switch == true then
        -- Swithces Bg color every line
        if (y % 2 == 0) then
            monitor.setBackgroundColor(bg1)
        else
            monitor.setBackgroundColor(bg2)
        end
    end
    
    -- Draw name
    local _, _, itemName = string.find(choosenitem, ":(.*)")
    monitor.write(itemName)
    monitor.write(string.rep(" ",width))


    -- Draw Stored amount
    indexofItem = getIndexofItem(choosenitem)

    monitor.setCursorPos(x + storedOffset,y)
    if not indexofItem  == false then
        monitor.write(meStats[indexofItem].stats[1])
        
    else
        monitor.write("0")
    end

    --  ______________________________________________________________________________
    --  Add a varable for how many increae should be shown also the               |
    --  varivale of how strong they should me like not every 10 60 600 seconds    |
    --  but 60 600 3600 or similar                                                V

    -- Draw increase
    monitor.setCursorPos(x + increaseOffset, y)

    if not indexofItem  == false then
        if displayIncrease then
            if meStats[indexofItem].stats[10] then
                increase = (meStats[indexofItem].stats[1] - meStats[indexofItem].stats[10]) / 10
                monitor.write(increase)
            else
                monitor.write("Wait")
            end
            monitor.setCursorPos(x + increaseOffset + 7, y)
            if meStats[indexofItem].stats[60] then
                increase = (meStats[indexofItem].stats[1] - meStats[indexofItem].stats[60]) / 60
                monitor.write(increase)
            else
                monitor.write("Wait")
            end
            monitor.setCursorPos(x + increaseOffset + 14, y)
            if meStats[indexofItem].stats[600] then
                increase = (meStats[indexofItem].stats[1] - meStats[indexofItem].stats[600]) / 600
                monitor.write(increase)
            else
                monitor.write("Wait")
            end
        end
    else
        monitor.write("Wait   Wait   Wait")
    end
end

local function getMonitorSize()
    monX , monY = monitor.getSize()
    return monX, monY
end

local function tracker()
    storeMeStats()
end

local function touchHandler()
    local event, side, x, y = os.pullEvent("monitor_touch")
end

local function diplayStats()
    while true do
        width, height = getMonitorSize()
        monitor.setBackgroundColor(colors.black)
        monitor.setTextColor(colors.white)
        monitor.setCursorPos(width/2 - 14,1)
        monitor.write("Items stats of the Me System")
        monitor.setPaletteColor(colors.black,0x000000)
        monitor.setPaletteColor(colors.gray,0x0b0b0b)
        local lastData = meStats[#meStats]

        for i, name in pairs(chosenItems) do
            drawItemData(1,3 + i,colors.white,true,colors.black,colors.gray,true,name)
        end
        sleep(1) -- Start the function every second instead 
                --of after every sencond to be more percise and not hardware thingy
    end

end

local function startMonitor()
    screen = "Stats"
    monitor.clear()
end

local function main()
    startMonitor()
    parallel.waitForAny(storeMeStats, diplayStats)
end

main()
