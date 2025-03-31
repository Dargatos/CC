mainpackages = package.path


package.path = "../../?.lua;../../?/init.lua;" .. package.path
print("Package path: ", package.path)
local telem = require("telem")

package.path = package.path .. ";../lib/?.lua"

local tuff = require("tuff")

local mainMonitor = peripheral.wrap("left")
local secondMon = peripheral.wrap("right")

mainMonitor.setTextScale(.5)

local mainFrame = tuff.Frame({
    monitor = mainMonitor,
    bgColor = colors.red
})

local settFrame = tuff.Frame({
    bgColor = colors.white,
    monitor = secondMon
})

function Buttonfunction()
    print("Hii how ya doing")
    tuff.render(settFrame)
end




local btn  = mainFrame:addComponent({
    type = "Button",
    xPos = 3,
    yPos = 3,
    width = 8,
    height = 3,
    monitor = mainMonitor,
    command = Buttonfunction,
    text = "Button",
    txColor = colors.red
})

local label = mainFrame:addComponent({
    type = "Label",
    xPos = 1,
    yPos = 1,
    monitor = mainMonitor,
    text = "Heyaaaa",
    txColor = colors.white
})

local Ilabel = mainFrame:addComponent({
    type = "Label",
    xPos = 15,
    yPos = 1,
    monitor = mainMonitor,
    text = "Items:",
    txColor = colors.white
})

local Vlabel = mainFrame:addComponent({
    type = "Label",
    xPos = 15,
    yPos = 3,
    monitor = mainMonitor,
    text = "0",
    txColor = colors.white,
    autoUpadte = true
})

local testlabel = settFrame:addComponent({
    type = "label",
    xPos = 5,
    yPos = 5,
    monitor = mainMonitor,
    text = "I will Kill you !",
    txColor = colors.red,
    bgColor = colors.white
})

local Item_list = mainFrame:addComponent({
    type = "list",
    monitor = mainMonitor,
    xPos = 5,
    yPos = 5,
    width = 40,
    height = 10,
    headers = {"Item", "Amount"},
    items = {},
    onSelect = function(selectedItem, rowIndex)
        change_selection(selectedItem, rowIndex)
    end
})



name =  "minecraft:chest_0"
chest = peripheral.wrap(name)

for slot, item in pairs(chest.list()) do
    print(("%d x %s in slot %d"):format(item.count, item.name, slot))
end



local function checkChest()
    while true do
        
        items = {}
        print("Checks")
        for slot, item in pairs(chest.list()) do
            local name = item.name

            if not items[name] then
                items[name] = 0
            end
            items[name] = items[name] + item.count
            --print(("%d x %s in slot %d"):format(item.count, item.name, slot))
        end
        
        local itemList = {}
        for name, count in pairs(items) do
            
            table.insert(itemList, {name, tostring(count)}) -- Convert count to string
        end

        for name, count in pairs(items) do
            --print(("%d x %s"):format(count, name))
        end
        Vlabel:update({
            
            text = items["minecraft:stripped_oak_wood"]
        })
        sleep(.5)
        Item_list:update({
            items = itemList
        })

        update_backplane_val()




    end
end

local Selected_Item = 1

local function tuffTouch()
    tuff:touch()
end

local function tuffRender()
    while true do
        print("Render")
        tuff.render(mainFrame)
        sleep(3)
    end
end
tuff.clearAll()
tuff.render(mainFrame)




------------------------------------------------------------------------------------------
-- Backplane stuff (Telem)
secondMon.setTextScale(0.5)
local monw, monh = secondMon.getSize()

local win = window.create(secondMon, 1, 1, monw, monh)

local backplane = telem.backplane()

backplane:addOutput('monitor_rand1', telem.output.plotter.line(win, 'rand', colors.black, colors.red))



function change_selection(selectedItem, rowIndex)
    print("Selected item: " .. selectedItem[1] .. ", Amount: " .. selectedItem[2])
    Selected_Item = rowIndex
end


function update_backplane_val()
    rowIndex = Selected_Item
    local selecteditem = Item_list.items[rowIndex]
    if selecteditem then
        item_amount = selecteditem[2]
    end

    -- Check if backplane exists
    if backplane then
        -- Remove the previous input by setting it to nil (manual removal approach)
        if currentInput then
            print("Removing previous input.")
            -- There is no explicit 'removeInput' so we reset the input manually
            -- Reset the input by not using it anymore
            -- (You can add logic to manage the removal based on the Telem API)
            currentInput = nil
        end
        -- Create a new input for the selected item
        currentInput = telem.input.custom(function ()
            -- Simulate with the selected item amount
            return { rand = tonumber(item_amount
        ) }
        end)

        -- Add the new input with a unique identifier
        backplane:addInput('selected_metric', currentInput)

        -- Ensure the output is properly updated with the correct key

    else
        print("Backplane not initialized.")
    end
end



local function main()
    print("Check main")
    parallel.waitForAny(checkChest, tuffTouch, tuffRender, backplane:cycleEvery(.2))
end

main()
