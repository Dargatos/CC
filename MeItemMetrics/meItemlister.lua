
-- Adding peripherals
local monitor = peripheral.find("monitor")
local me = peripheral.find("meBridge")
Screen = "Stats"

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

SettingsButtons = {
    label = "General Settings",
    xPos = 1,
    yPos = 3,
    kind = "x",
    buttons = {
        [1] = {name = "Add/Remove Items"},
        [2] = {name = "Select Monitor"},
        [3] = {name = "Graph Settings"},
        [4] = {name= "Increase Settings"}
    }
}

Add_RemoveOptionsList = {
    xPos = 23,
    yPos = 5,
    kind = "itself",
    buttons={
        [1] = {name = "Write in terminal"},
        [2] = {name = "Use chest"},
        [3] = {name = "<Adding>"},
        [4] = {name = "Priority",value = 1},
        [5] = {name = "Use terminal"}
    }
}
MeStats = {}
MaxData = 700
local function savetData(meitem)
    -- Checks if there is already a table
    local noTable = true
    if #MeStats == 0 then 
        noTable = true 
    end
    for i, item in pairs(MeStats) do
        if item.name == meitem.name then
            noTable = false
            break
        end
    end

    -- if there is no table create and stores the new one
    if noTable == true then

        table.insert(MeStats,{name = meitem.name,stats = {}})
    end

    -- Saves the data in the table
    for i, entry  in pairs(MeStats) do
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

        if #MeStats > MaxData then
            table.remove(MeStats,1)
        end
        print("Stats Saved")
        sleep(1)
    end
end


-- Im bad at remembering so for my brain some copys fo string functions
-- sixhundred_sec = string.format("%.2f/h", sixhundred_sec)  -- Round to 2 decimal places
-- sixty_sec = string.format("%.0f/m", sixty_sec)  -- Round to 2 decimal places
-- ten_sec = string.format("%.2f/s", ten_sec)  -- Round to 2 decimal places

function FormatWithDots(number)
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
        monitor.write(FormatWithDots(last_value))
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

local function drawButtonList(monitor,list)
    local btnDistance = list.btnDistance
    local label = list.label
    local xPos = list.xPos
    local yPos = list.yPos
    local headcolor = list.headcolor or colors.green
    local tc = list.textcolor or colors.white
    local bg = list.backgroundcolor or colors.black
    local anchor = list.anchor or "right"
    local yoffset = list.yoffset or 1
    local kind = list.kind or false

    if not label then
        yoffset = 0
    end

    -- calculates longest label
    if not btnDistance then
        btnDistance = 0
        for i, item in pairs(list.buttons) do
            if #item.name > btnDistance then
                btnDistance = #item.name
            end
        end
        btnDistance = btnDistance + 1 
        list["btnDistance"] = btnDistance
    end

    monitor.setCursorPos(xPos,yPos)
    monitor.setBackgroundColor(bg)
    monitor.setTextColor(headcolor)

    if label then 
        monitor.write(label)
        yPos = yPos + yoffset
    else
        yPos = yPos -1
    end

    monitor.setTextColor(tc)
    for i, btn in pairs(list.buttons) do

        if kind == "itself" then
            monitor.setBackgroundColor(colors.gray)
        else
            monitor.setBackgroundColor(bg)
        end

        monitor.setCursorPos(xPos,yPos + i)
        monitor.write(btn.name)
        monitor.setBackgroundColor(colors.green)
        monitor.setCursorPos(xPos + btnDistance,yPos + i)
        
        -- Saves position of placed button in list.
        list.buttons[i]["x"] = xPos + btnDistance
        list.buttons[i]["y"] = yPos + i
        
        if kind == "x" then
            monitor.write("x")
        elseif kind == "o" then
            monitor.write("o")
        elseif not kind then
            monitor.write(" ")
        end
    end
end

local function getIndexofItem(choosen)
    for i, meItem in pairs(MeStats) do
        if choosen == meItem.name then
            return i
        end
    end
    return false
end
local function displaySettingsWindow()
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    monitor.setCursorPos((Width / 2) - 4, 1)
    monitor.write("Settings")

    -- Just a button for Debug
    monitor.setCursorPos(Width,Height)
    monitor.setBackgroundColor(colors.blue)
    monitor.write(" ")

    drawButtonList(monitor,SettingsButtons)
    

    --monitor.write("place items to add or remove in chest !")
end
local function drawItemData(x,y,textcolor,switch,bg1,bg2,displayIncrease,choosenitem,storedOffset,increaseOffset)
    local storedOffset = storedOffset or 19
    local increaseOffset = increaseOffset or 11
    local increaseOffset = increaseOffset + storedOffset
    local indexofItem = getIndexofItem(choosenitem)

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
    monitor.write(string.rep(" ",Width))


    -- Draw Stored amount
    

    monitor.setCursorPos(x + storedOffset,y)
    if not indexofItem  == false then
        monitor.write(MeStats[indexofItem].stats[1])
        
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
            if MeStats[indexofItem].stats[10] then
                local increase = (MeStats[indexofItem].stats[1] - MeStats[indexofItem].stats[10]) / 10
                print(increase)
                if increase >= 0 then
                    monitor.write(" "..increase)
                else
                   monitor.write(increase)
                end
            else
                monitor.write(" ".."Wait")
            end
            monitor.setCursorPos(x + increaseOffset + 7, y)
            if MeStats[indexofItem].stats[60] then
                local increase = (MeStats[indexofItem].stats[1] - MeStats[indexofItem].stats[60]) / 60
                if increase >= 0 then
                    monitor.write(" "..increase)
                else
                   monitor.write(increase)
                end
            else
                monitor.write(" ".."Wait")
            end
            monitor.setCursorPos(x + increaseOffset + 14, y)
            if MeStats[indexofItem].stats[600] then
                local increase = (MeStats[indexofItem].stats[1] - MeStats[indexofItem].stats[600]) / 600
                if increase >= 0 then
                    monitor.write(" "..increase)
                else
                   monitor.write(increase)
                end
            else
                monitor.write(" ".."Wait")
            end
        end
    else
        monitor.write(" Wait   Wait   Wait")
    end
end

local function getMonitorSize()
    local monX , monY = monitor.getSize()
    return monX, monY
end

local function tracker()
    storeMeStats()
end

local function touchHandler()
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")
        print(x,y)
        
        print(Screen)
        if Screen == "Settings" then
            -- Just for Debug purpose
            if x == Width and y == Height then
                print (SettingsButtons.buttons[4].y)
            end
            
            -- Checks if input is at the x Value of the buttons of the list
            if x == SettingsButtons.btnDistance + SettingsButtons.xPos then

                if y == SettingsButtons.buttons[1].y then
                    --Draw new list of Buttons
                    drawButtonList(monitor,Add_RemoveOptionsList)
                end
                if y == SettingsButtons.buttons[2].y then

                end
                if y == SettingsButtons.buttons[3].y then
                    
                end
                if y == SettingsButtons.buttons[4].y then
                    
                end
            end
        end
        if x == Width and y == 1 then
            Screen = "Settings"
        end
    end
end

local function diplayStats()    
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.setCursorPos(Width/2 - 14,1)
    monitor.write("Items stats of the Me System")
    monitor.setPaletteColor(colors.black,0x000000)
    monitor.setPaletteColor(colors.gray,0x0b0b0b)

    for i, name in pairs(chosenItems) do
        drawItemData(1,3 + i,colors.white,true,colors.black,colors.gray,true,name)
    end
end

local function displayWindow()
    local displayed = false
    while true do
        if Screen == "Stats" then
            diplayStats()
            displayed = false
        elseif Screen == "Settings"  and displayed == false then
            displaySettingsWindow()
            displayed = true
        end
        sleep(1)-- Start the function every second instead 
        --of after every sencond to be more percise and not hardware thingy
    end
    
end

local function startMonitor()
    Screen = "Stats"
    Width, Height = getMonitorSize()
    monitor.clear()
end

local function main()
    startMonitor()
    parallel.waitForAny(storeMeStats, displayWindow,touchHandler)
end

main()
