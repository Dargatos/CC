package.path = "../../?.lua;../../?/init.lua;" .. package.path
package.path = package.path .. ";./tuff/?.lua"
package.path = package.path .. ";../../tuff/?.lua"

local telem = require("telem")
local tuff = require("tuff")

local mainMonitor = peripheral.wrap("left")
local secondMon = peripheral.wrap("top")
local coolantMon = peripheral.wrap("right")
mainMonitor.setTextScale(1.5)
secondMon.setTextScale(1.5)

local mainFrame = tuff.Frame({
    monitor = mainMonitor,
    bgColor = colors.black
})


local label = mainFrame:addComponent({
    type = "label",
    xPos = 5,
    yPos = 1,
    monitor = mainMonitor,
    text = "Reactor Controller",
    txColor = colors.white
})

local status_l = mainFrame:addComponent({
    type = "label",
    xPos = 5,
    yPos = 2,
    monitor = mainMonitor,
    text = "Status: Unkown",
    txColor = colors.orange,
    bgColor = colors.gray,
    height = 1
})

local selftart_btn  = mainFrame:addComponent({
    type = "button",
    xPos = 2,
    yPos = 3,
    monitor = mainMonitor,
    command = function() startReactor() end,
    text = "Start",
    txColor = colors.white,
    bgColor = colors.green
})

local scram_btn  = mainFrame:addComponent({
    type = "button",
    xPos = 12,
    yPos = 3,
    monitor = mainMonitor,
    command = function() scramReactor() end,
    text = "SCRAM",
    txColor = colors.white,
    bgColor = colors.red
})

local fuel_label  = mainFrame:addComponent({
    type = "label",
    xPos = 2,
    yPos = 7,
    monitor = mainMonitor,
    text = "Fuel Rate:",
    txColor = colors.white,
    bgColor = colors.black
})

local fuel_rate  = mainFrame:addComponent({
    type = "label",
    xPos = 13,
    yPos = 7,
    monitor = mainMonitor,
    text = "nil",
    txColor = colors.yellow,
    bgColor = colors.black
})

local inc100_btn  = mainFrame:addComponent({
    type = "button",
    xPos = 2,
    yPos = 9,
    monitor = mainMonitor,
    text = "Incr:100",
    txColor = colors.blue,
    bgColor = colors.black,
    height = 1,
    command = function() increaseFuel(100) end
})

local dec100_btn  = mainFrame:addComponent({
    type = "button",
    xPos = 14,
    yPos = 9,
    monitor = mainMonitor,
    text = "Dec:100",
    txColor = colors.pink,
    bgColor = colors.black,
    height = 1,
    command = function() increaseFuel(-100) end
})

local inc10_btn  = mainFrame:addComponent({
    type = "button",
    xPos = 2,
    yPos = 10,
    monitor = mainMonitor,
    text = "Incr:10",
    txColor = colors.blue,
    bgColor = colors.black,
    height = 1,
    command = function() increaseFuel(10) end
})

local dec10_btn  = mainFrame:addComponent({
    type = "button",
    xPos = 14,
    yPos = 10,
    monitor = mainMonitor,
    text = "Dec:10",
    txColor = colors.pink,
    bgColor = colors.black,
    height = 1,
    command = function() increaseFuel(-10) end
})

local errorbtn = mainFrame:addComponent({
    type = "button",
    xPos = -10,
    yPos = -20,
    monitor = mainMonitor,
    text = "Error",
    txColor = colors.red,
    bgColor = colors.white,
    width = 20,
    height = 7,
    command = function() hideError() end
})

local FuelRate = 0
local turbineSide
local reactorport
local maxBurn
local reac_status -- boolean
local wastePercentage
local heatedCoolantFilledPercentage
local ignore = false
local coolantFillPerc

local maxWasteFill = .9
local maxHCollantFill = nil
local minCollantFillPerc = .7
-- Finding the turbine side
for i, side in ipairs(peripheral.getNames()) do
    print(i,peripheral.getType(side))
    if peripheral.getType(side) == "turbineValve" then
        turbineSide = side
    end
    if peripheral.getType(side) == "fissionReactorLogicAdapter" then
        reactorport = side
    end
end


function startup()
    reac_status = peripheral.call(reactorport, "getStatus")
    check_stats()
    maxBurn = peripheral.call(reactorport, "getMaxBurnRate")
    FuelRate = peripheral.call(reactorport, "getBurnRate")
    fuel_rate:update({text = tostring(FuelRate)})
    reac_status = peripheral.call(reactorport, "getStatus")
    if reac_status == true then 
        status_l:update({text = "Status: Running"})
    else
        status_l:update({text = "Status: SCRAM"})
    end

    coolantFillPerc = peripheral.call(reactorport, "getCoolantFilledPercentage")
    print("Collant Fill = " .. coolantFillPerc)

end


function check_stats()
    local DANGER = false
    local Warning = false 
    wastePercentage = peripheral.call(reactorport, "getWasteFilledPercentage")
    if wastePercentage >= maxWasteFill then 
        scramReactor() 
        DANGER = true
    end

    heatedCoolantFilledPercentage = peripheral.call(reactorport, "getHeatedCoolantFilledPercentage")
    if heatedCoolantFilledPercentage == 1 then 
        showError("heated Collant Filled") 
        Warning = true
    elseif heatedCoolantFilledPercentage == maxHCollantFill then 
        scramReactor() 
        DANGER = true
    end
    
    reac_status = peripheral.call(reactorport, "getStatus")
    if reac_status == true then 
        status_l:update({text = "Status: Running"})
    else
        status_l:update({text = "Status: SCRAM"})
    end

    FuelRate = peripheral.call(reactorport, "getBurnRate")

    coolantFillPerc = peripheral.call(reactorport, "getCoolantFilledPercentage")
    if coolantFillPerc < minCollantFillPerc then 
        DANGER = true
        scramReactor()
    elseif coolantFillPerc < .95 then 
        Warning = true
    end

    return DANGER, Warning
end

function hideError()
    ignore = true
    errorbtn:update({xPos = -20, yPos = -20, text = "Error Unknown"})
end

function showError(message)
    if ignore == true then return end
    print(message)
    errorbtn:update({xPos = 3, yPos = 4, text = "Error " .. message or "Unkown"})
    print("Error " .. message)
end

function increaseFuel(amount)
    -- Inscreases or Decreases fuel
    print("Increaseing fuel by" .. amount)
    FuelRate = FuelRate + amount
    if FuelRate < 0 then
        FuelRate = 0
    elseif FuelRate > maxBurn then
        FuelRate = maxBurn
    end
    peripheral.call(reactorport, "setBurnRate", FuelRate)
    fuel_rate:update({text = tostring(FuelRate)})
end


---------------------------------------------------------------------
-- Start Stop Reactor --
function scramReactor()
    if reac_status == false then return end

    print("Scraming !!!")
    peripheral.call(reactorport, "scram")

end

function startReactor()
    if reac_status == true then return end
    local Danger, _ = check_stats()
    if Danger == true then return end
    print("Starting")
    peripheral.call(reactorport, "activate")
    -- maybe add an auto start ....
    -- small steps like first 100 than 200 as small as possible

end


local function tuffTouch()
    tuff:touch()
end

local function tuffRender(time)
    time = .1
    while true do
        tuff.render(mainFrame)
        sleep(time)
    end
end

local function check()
    while true do
        check_stats()
        sleep(.05)
    end
end


-- Telem ----------------------------------------
secondMon.setTextScale(.5)
local monw, monh = secondMon.getSize()

local win = window.create(secondMon, 1, 1, monw, monh)

local backplane = telem.backplane()

backplane:addOutput('TempMon', telem.output.plotter.line(win, 'temp', colors.black, colors.green))

coolantMon.setTextScale(.5)
local monw, monh = coolantMon.getSize()
local collantwin = window.create(coolantMon, 1, 1, monw, monh)
local coolantback = telem.backplane()

coolantback:addOutput('coolantMon', telem.output.plotter.line(collantwin, 'coolant', colors.black, colors.white, nil, 0, 1.1))

local grafanabackplane = telem.backplane()

local authGrafana2 = {
    endpoint = 'http://localhost:3003/telegraf',
    apiKey = ""
}

grafanabackplane:addInput('fission', telem.input.mekanism.fissionReactor('fissionReactorLogicAdapter_0'))
--grafanabackplane:addInput('Mesys', telem.input.itemStorage('meBridge_0'))
grafanabackplane:addInput('turbine', telem.input.mekanism.industrialTurbine('turbineValve_0'))
grafanabackplane:addInput('turbine1', telem.input.mekanism.industrialTurbine('turbineValve_1'))
grafanabackplane:addInput('turbine2', telem.input.mekanism.industrialTurbine('turbineValve_2'))
grafanabackplane:addOutput('grafana', telem.output.grafana(authGrafana2.endpoint, authGrafana2.apiKey))
function update_temp()
    while true do
        reactor_collant = peripheral.call(reactorport, "getCoolantFilledPercentage")
        print(reactor_collant)
        reactor_temp = peripheral.call(reactorport, "getTemperature")
        tempInput = telem.input.custom(function ()
            -- Simulate with the selected item amount
            return { temp = reactor_temp}
        end)

        coolantInput = telem.input.custom(function ()
            -- Simulate with the selected item amount
            return { coolant = reactor_collant}
        end)
        
        
        coolantback:addInput('coolantPerc', coolantInput)
        backplane:addInput('reactemp', tempInput)
        sleep(1)
    end
end














local function main()
    startup()
    parallel.waitForAny(tuffRender, tuffTouch, update_temp, backplane:cycleEvery(1),coolantback:cycleEvery(1),check, grafanabackplane:cycleEvery(1))
end

main()