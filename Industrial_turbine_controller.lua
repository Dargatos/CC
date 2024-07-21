turbine = peripheral.find("turbineValve")
monitor = peripheral.find("monitor")
local turbineSide
local turbineValues = {
    {command = "getBlades", value = false, name = "Blades"},
    {command = "getCoils",value = false, name= "Coils"},
    {command = "getCondensers",value = false, name= "Condesers"},
    {command = "getDispersers",value = false, name= "Dispersers"},
    {command = "getDumpingMode",value = true, name= "DumpingMode"},
    {command = "getLastSteamInputRate",value = true, name= "SteamInput"},
    {command = "getMaxFlowRate",value = false, name= "MaxFlowRate"},
    {command = "getMaxProduction",value = true, name= "MaxProduction"},
    {command = "getMaxWaterOutput",value = false, name= "MaxWaterOutput"},
    {command = "getProductionRate",value = true, name= "ProductionRate"},
    {command = "getSteam",value = false, name= "Steam"},
    {command = "getSteamCapacity",value = false, name= "SteamCapacity"},
    {command = "getSteamFilledPercentage",value = true, name= "SteamPercentage"},
    {command = "getSteamNeeded",value = false, name= "SteamNeeded"},
    {command = "getVents",value = false, name= "Vents"},
    {command = "getEnergy",value = true, name= "EnergyStored"},

}

for _, side in ipairs(peripheral.getNames()) do
    if peripheral.getType(side) == "turbineValve" then
        turbineSide = side
        
        break  -- Exit loop once the modem is found
    end
end

function redstone(side,value)
    rs.setOutput(side,value)
end
function getstats()
    j = 1
    --monitor.clear()
    for i, stat in ipairs(turbineValues) do
        
        --print(stat.name,stat.command,stat.value)
        if stat.value == true then
            local value = peripheral.call(turbineSide,stat.command)
            if stat.name == "SteamPercentage" then
                if value > .9 then
                    redstone("bottom", true)
                    print("Turbine full shutting reactor down")
                else
                    redstone("bottom", false)
                end
                print (value)
                value = string.format("%.2f%%",value * 100)
                print (value)
                
            end


            if stat.name == "EnergyStored" then
                value = string.format("%.2f mFe",value * 0.4)
            end
            --str = string.format("%s :",stat.name,value)
            monitor.setCursorPos(1,j)
            monitor.write(stat.name .. ": " .. value)
            j = j +1
        end
    end
end
function main()
    monitor.clear()
    monitor.setTextScale(1.5)
    while true do
        getstats()
        sleep(1)
    end
end
main()

