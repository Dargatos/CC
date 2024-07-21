
local slot_positions = {} -- list of all item found in inv (position in table relates to inv position)
local necessaryitems = {"mekanism:digital_miner",
"mekanism:elite_logistical_transporter",
"enderstorage:ender_chest",
"fluxnetworks:flux_point"}
local modemSide

local function setAsStartup(scriptName)
    local startupScript = 'shell.run("' .. scriptName .. '")\n'
    
    -- Check if the startup file exists
    if fs.exists("startup") then
        -- Open the startup file for reading
        local file = fs.open("startup", "r")
        local content = file.readAll()
        file.close()
        
        -- Check if the startup file already contains the necessary command
        if content:find(scriptName) then
            print("Startup file already contains the command to run " .. scriptName)
            return
        end
    end

    -- Open the startup file for writing (this will create the file if it doesn't exist)
    local file = fs.open("startup", "w")
    file.write(startupScript)
    file.close()
    print("Script set as startup.")
end
setAsStartup(shell.getRunningProgram())



local function getModemSide()
    -- Get all peripheral names and find which one is a modem
    for _, side in ipairs(peripheral.getNames()) do
        if peripheral.getType(side) == "modem" then
            modemSide = side
            print("Modem is",side)
            rednet.open(side)
            break  -- Exit loop once the modem is found
        end
    end
    if not modemSide then
        printError("No Modem found. Pls install a modem")
        error()
    end
end

function search_items()
    for i = 1,16 do
        local item = turtle.getItemDetail(i)
        if item then
            slot_positions[i] = item
        else
            slot_positions[i] = "None"
        end
    end
end        



function get_slot_position(item)
    for i, slot in ipairs(slot_positions) do
        if slot.name == item then
            return i
        end
    end
    return "None"
end

local function getFuel()
    level = turtle.getFuelLevel()
    if level < Repetitions * 70 then
        print("pls insert fuel and press enter")
        while true do

            input = read()
            if input == "stop" then
                printError("Startup enden due to User")
                error()
            end
            turtle.refuel()
            newlevel = turtle.getFuelLevel()
            if newlevel == 0 then
                print ("No fuel detected pls try again")
            elseif newlevel > 0 then
                print("New Fuel level is " .. newlevel)
                break
            end
        end
    else
        print("Fuel Level is: ",turtle.getFuelLevel())
    end
end

local function checkItems()
    search_items()
    
    for i , item in ipairs(necessaryitems) do
        if get_slot_position(item) == "None" then
            printError(item," not found")
            print("insert all items and press enter")
            return false
        end
    end
    return true
    
end

function placing_all_blocks()
    rednet.send(13,"Building miner",stat_proto)
    search_items()
    local miner = get_slot_position("mekanism:digital_miner")
    local logistical = get_slot_position("mekanism:elite_logistical_transporter")
    local ender_storage = get_slot_position("enderstorage:ender_chest")
    local energy =  get_slot_position("fluxnetworks:flux_point")
    sleep(2)
    turtle.select(logistical)
    turtle.placeUp()

    turtle.select(ender_storage)
    turtle.down()
    turtle.placeUp()

    turtle.select(miner)
    turtle.forward()
    turtle.forward()
    turtle.turnLeft()
    turtle.turnLeft()
    turtle.placeUp()

    turtle.select(energy)
    turtle.turnRight()
    turtle.forward()
    turtle.forward()
    turtle.placeUp()

    turtle.turnLeft()
    turtle.turnLeft()
    turtle.forward()
    turtle.forward()
    start_miner()


end

function break_miner()
    turtle.digUp()
    turtle.turnLeft()
    turtle.turnLeft()
    turtle.forward()
    turtle.forward()
    turtle.digUp()
    turtle.turnLeft()
    turtle.forward()
    turtle.forward()
    turtle.turnLeft()
    turtle.forward()
    turtle.forward()
    turtle.digUp()
    turtle.up()
    turtle.digUp()
    turtle.turnLeft()
end

function start_miner()
    peripheral.call("top","start")
end


function main()
    getFuel()
    while true do
        check =  checkItems()
        if check ==  true then
            break
        end
        agfaf = read()
    end
    local whitlist_protocol = "Digital_miner_builder"
    local channelId = peripheral.call("top", "getID")
    if not channelId then
        printError("No chunk turtle found")
        error()
    end
    local stat_proto = "Stating_prot"
    local firstStart = true


    print("Starting..")
    print("channel:",channelId,"Proto",whitlist_protocol)

    rednet.open(modemSide)
    

    rednet.send(channelId,"start",whitlist_protocol)

    for i = 1, 10 do
        turtle.forward()
    end

    for i = 1, Repetitions do
        
        if firstStart == false then
            print(channelID)
            rednet.send(13,string.format("moving to next position",whitlist_protocol),stat_proto)
            rednet.send(channelId,"move",whitlist_protocol)

            for i = 1, 64 do
                turtle.forward()
            end
        end
        firstStart = false

        placing_all_blocks() --Places miner
        while true do
            local to_mine = peripheral.call("top","getToMine")
            rednet.send(13,string.format("Blocks left to mine %d",to_mine),stat_proto)
            if to_mine == 0 then
                sleep(1)
                rednet.send(15,"Breaking miner",stat_proto)
                print("stopped")
                break
            end
            sleep(2)
        end
        break_miner()
    end
    rednet.send(13,string.format(whitlist_protocol,"Is Done"),stat_proto)
    print("Turtle stopped")
end
getModemSide()
print("Hom many repeats ?")
local Repetitions_str = read()
Repetitions = tonumber(Repetitions_str)
print("type start to start")
while true do
    local input = read()
    if input == "start" then
        main()
        break
    else
        print("thats not start")
    end
end
--print(get_slot_position("mekanism:elite_logistical_transporter"))

--turtle.select("mekanism:digital_miner")
--trutle.placeUp()
--turtle.select("mekanism:elite_logistcal_transporter")
--trutle.backward(2)