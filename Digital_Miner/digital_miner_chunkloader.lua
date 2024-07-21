
local whitlist_protocol = "Digital_miner_builder"
local id 
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
    end
end

local function getFuel()
    level = turtle.getFuelLevel()
    if level == 0 then
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

local function recieving()
    while true do
        local idd, message, protocol = rednet.receive()
        print(idd)
        if whitlist_protocol == protocol and idd == id then
            print(message)
            if message == "move" then   
                for i = 1, 64 do
                    turtle.forward()
                end
            elseif message == "start" then
                turtle.up()
                for i = 1 ,8 do
                    turtle.forward()
                end
            end

        end
    end
end

local function main()
    getModemSide()
    
    getFuel()
    while true do
        inp = read()
        if inp == "refuel" then
            turtle.refuel()
        end
        if inp == "start" then
            break
        end
    end
    id = peripheral.call("bottom", "getID")
    if not id then
        printError("No miner turtle found")
        error()
    end
    print("Start recieving from:",id,"with",whitlist_protocol,"protocol")
    recieving()
end

main()