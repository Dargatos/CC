-- Peripheral setup
local turbine = peripheral.find("turbineValve")
local monitor = peripheral.find("monitor")
local turbineSide

local turbineValues = {
    {command = "getBlades", value = false, name = "Blades"},
    {command = "getCoils", value = false, name = "Coils"},
    {command = "getCondensers", value = false, name = "Condensers"},
    {command = "getDispersers", value = false, name = "Dispersers"},
    {command = "getDumpingMode", value = true, name = "DumpingMode"},
    {command = "getLastSteamInputRate", value = true, name = "SteamInput"},
    {command = "getMaxFlowRate", value = false, name = "MaxFlowRate"},
    {command = "getMaxProduction", value = true, name = "MaxProduction"},
    {command = "getProductionRate", value = true, name = "ProductionRate"},
    {command = "getSteam", value = false, name = "Steam"},
    {command = "getSteamCapacity", value = false, name = "SteamCapacity"},
    {command = "getSteamFilledPercentage", value = true, name = "SteamPercentage"},
    {command = "getSteamNeeded", value = false, name = "SteamNeeded"},
    {command = "getVents", value = false, name = "Vents"},
    {command = "getEnergy", value = true, name = "EnergyStored"}
}

-- Finding the turbine side
for _, side in ipairs(peripheral.getNames()) do
    if peripheral.getType(side) == "turbineValve" then
        turbineSide = side
        break
    end
end

-- Helper function to control redstone output
local function redstone(side, value)
    rs.setOutput(side, value)
end

-- Function to retrieve turbine statistics
local function getStats()
    local stats = {}
    for _, stat in ipairs(turbineValues) do
        if stat.value then
            local value = peripheral.call(turbineSide, stat.command)
            if stat.name == "SteamPercentage" then
                value = string.format("%.2f%%", value * 100)
            elseif stat.name == "EnergyStored" then
                value = string.format("%.2f mFe", value * 0.4)
            end
            table.insert(stats, {name = stat.name, value = tostring(value)})
        end
    end
    return stats
end

-- Function to display the control UI on the main terminal
local function displayControlUI()
    term.clear()
    term.setCursorPos(1, 1)
    print("Select the values to display on the monitor:")
    for i, stat in ipairs(turbineValues) do
        print(string.format("[%d] %s - %s", i, stat.value and "X" or " ", stat.name))
    end
    print("\nPress 'q' to switch to Display mode")
end

-- Function to display stats on the monitor
local function displayStats(stats)
    monitor.clear()
    monitor.setCursorPos(1, 1)
    for i, stat in ipairs(stats) do
        monitor.setCursorPos(1, i)
        monitor.write(stat.name .. ": " .. stat.value)
    end
end

-- Function to toggle a turbine value display setting
local function toggleTurbineValue(index)
    if index >= 1 and index <= #turbineValues then
        turbineValues[index].value = not turbineValues[index].value
    end
end

-- Main program loop
local function main()
    local mode = "control"
    monitor.setTextScale(1.5)

    while true do
        if mode == "control" then
            displayControlUI()
            local event, key = os.pullEvent("key")
            if key == keys.q then
                mode = "display"
            elseif key >= keys.one and key <= keys.nine then
                toggleTurbineValue(key - keys.one + 1)
            end
        else -- display mode
            local stats = getStats()
            displayStats(stats)
            local timer = os.startTimer(1)
            local event, param = os.pullEvent()
            if event == "key" and param == keys.q then
                mode = "control"
            elseif event ~= "timer" then
                -- If it's not the refresh timer, we pull events until we get the timer
                -- This ensures we always wait for the full second
                repeat
                    event, param = os.pullEvent()
                until event == "timer" and param == timer
            end
        end
    end
end

-- Run the main program
main()