package.path = "../../?.lua;../../?/init.lua;" .. package.path
package.path = package.path .. ";./tuff/?.lua"

local telem = require("telem")
local tuff = require("tuff")

local mainMonitor = peripheral.wrap("left")
local secondMon = peripheral.wrap("top")
mainMonitor.setTextScale(1.5)
secondMon.setTextScale(1.5)

local mainFrame = tuff.Frame({
    monitor = mainMonitor,
    bgColor = colors.black
})


local label = mainFrame:addComponent({
    type = "label",
    xPos = 10,
    yPos = 1,
    monitor = mainMonitor,
    text = "Reactor Controller",
    txColor = colors.white
})

local selftart_btn  = mainFrame:addComponent({
    type = "button",
    xPos = 2,
    yPos = 3,
    monitor = mainMonitor,
    command = function() startReactor() end,
    text = "Start",
    txColor = colors.green
})

local scram_btn  = mainFrame:addComponent({
    type = "button",
    xPos = 12,
    yPos = 3,
    monitor = mainMonitor,
    command = function() scramReactor() end,
    text = "SCRAM",
    txColor = colors.red
})

local fuel_label  = mainFrame:addComponent({
    type = "label",
    xPos = 2,
    yPos = 7,
    monitor = mainMonitor,
    text = "Fuel Rate:",
    txColor = colors.white
})

local fuel_rate  = mainFrame:addComponent({
    type = "label",
    xPos = 13,
    yPos = 7,
    monitor = mainMonitor,
    text = "nil",
    txColor = colors.yellow
})

local inc100_btn  = mainFrame:addComponent({
    type = "button",
    xPos = 2,
    yPos = 8,
    monitor = mainMonitor,
    text = "Incr:100",
    txColor = colors.blue,
    height = 1,
    command = function() increaseFuel(100) end
})

local dec100_btn  = mainFrame:addComponent({
    type = "button",
    xPos = 14,
    yPos = 8,
    monitor = mainMonitor,
    text = "Dec:100",
    txColor = colors.pink,
    height = 1,
    command = function() increaseFuel(-100) end
})

local inc10_btn  = mainFrame:addComponent({
    type = "button",
    xPos = 2,
    yPos = 11,
    monitor = mainMonitor,
    text = "Incr:10",
    txColor = colors.blue,
    height = 1,
    command = function() increaseFuel(10) end
})

local dec10_btn  = mainFrame:addComponent({
    type = "button",
    xPos = 14,
    yPos = 11,
    monitor = mainMonitor,
    text = "Dec:10",
    txColor = colors.pink,
    height = 1,
    command = function() increaseFuel(-10) end
})

local FuelRate = 0
local turbineSide
local reactorport
local maxBurn

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
    maxBurn = peripheral.call(reactorport, "getMaxBurnRate")

end

function increaseFuel(amount)
    -- Inscreases or Decreases fule
    print("Increaseing fule by" .. amount)
    FuelRate = FuelRate + amount
    if FuelRate < 0 then
        FuelRate = 0
    elseif FuelRate > maxBurn then
        FuelRate = maxBurn
    end
   peripheral.call(reactorport, "setBurnRate", FuelRate)
    fuel_rate:update({text = tostring(FuelRate)})
end


function scramReactor()
    peripheral.call(reactorport, "scram")
    --insteand SCRAM
end

function startReactor()
    print("Starting")
    peripheral.call(reactorport, "activate")
    -- Start the reactor
    -- small steps like first 100 than 200 as small as possible
end


local function tuffTouch()
    tuff:touch()
end

local function tuffRender(time)
    local time = time or 1
    while true do
        print("Render")
        tuff.render(mainFrame)
        sleep(time)
    end
end




-- Telem ----------------------------------------
secondMon.setTextScale(.5)
local monw, monh = secondMon.getSize()

local win = window.create(secondMon, 1, 1, monw, monh)

local backplane = telem.backplane()

backplane:addOutput('TempMon', telem.output.plotter.line(win, 'temp', colors.black, colors.green))




function update_temp()
    while true do
        reactor_temp = peripheral.call(reactorport, "getTemperature")
        print(reactor_temp)
        currentInput = telem.input.custom(function ()
            -- Simulate with the selected item amount
            return { temp = reactor_temp}
        end)
        
        backplane:addInput('reactemp', currentInput)
        sleep(1)
    end
end














local function main()
    startup()
    parallel.waitForAny(tuffRender, tuffTouch, update_temp, backplane:cycleEvery(1))
end

main()