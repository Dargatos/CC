-- Adding peripherals
local monitor = peripheral.find("monitor")
local me = peripheral.find("meBridge")

-- Declaring tables
local list = {"minecraft:wheat","minecraft:cobblestone","mekanism:dust_sulfur", "minecraft:diamond","minecraft:iron_ingot","minecraft:redstone","minecraft:gold_ingot","malum:wicked_spirit","malum:arcane_spirit","malum:aerial_spirit","malum:earthen_spirit","malum:eldritch_spirit","mekanism:sodium"}

-- Build new table which stores the data (amount) of items in "list"
local function buildTable(list)
    local newList = {}
    for i, name in ipairs(list) do
        local item = {name = name, children = {}}
        table.insert(newList, item)
    end
    return newList
end

local table_list = buildTable(list)

local function add_amount_values(item_name, child_value)
    for i, item in ipairs(table_list) do
        if item.name == item_name then
            local count = #table_list[1].children
            table.insert(item.children, child_value)
            --if count > 700 then
            --    table.remove(item.children, 1)
            --end
            return true
        end
    end
    return false
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

    print(items)

    -- Searching for items in "list" and storing value in array
    for _, item_name in ipairs(list) do
        for _, item in pairs(items) do
            if item.name == item_name then
                --print ("Amount : ",item.amount)
                add_amount_values(item_name, item.amount)
                
            end
            
        end
        
    end
    return true
end



local function get_nth_child_value(item_name, n)
    
    for i, item in ipairs(table_list) do
        if item.name == item_name then
            if #item.children < n then
                return 0
            end
            return item.children[n] or 0
        end
    end
    return 0
end

local function clac_diff(name)
    local count = #table_list[1].children  -- Total number of data points
    local last_value = get_nth_child_value(name, count)  -- Get the last recorded value

    local ten_sec, sixty_sec, sixhundred_sec

    if count >= 10 then
        local ten_sec_value = get_nth_child_value(name, count - 10)  -- Value 10 positions ago
        ten_sec = (last_value - ten_sec_value) / 10 
        ten_sec = string.format("%.2f/s", ten_sec)  -- Round to 2 decimal places
    else
        ten_sec = "Wait"
    end

    if count >= 60 then
        local sixty_sec_value = get_nth_child_value(name, count - 60)  -- Value 60 positions ago
        sixty_sec = (last_value - sixty_sec_value)
        sixty_sec = string.format("%.0f/m", sixty_sec)  -- Round to 2 decimal places
    else
        sixty_sec = "Wait"
    end

    if count >= 600 then
        local sixhundred_sec_value = get_nth_child_value(name, count - 600)  -- Value 600 positions ago
        sixhundred_sec = (last_value - sixhundred_sec_value) / 600 * 60 * 60
        sixhundred_sec = string.format("%.2f/h", sixhundred_sec)  -- Round to 2 decimal places
    else
        sixhundred_sec = "Wait"
    end

    return {ten_sec, sixty_sec, sixhundred_sec}
end

local function formatWithDots(number)
    -- Convert the number to a string
    local numStr = tostring(number)

    -- Reverse the string to process from the end
    local reversed = string.reverse(numStr)

    -- Insert dots every three characters
    local withDots = reversed:gsub("(%d%d%d)", "%1 ")

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



local function main()
    while true do
        read_system_values()
        display_on_monitor()
        sleep(.6)
    end
end

main()
