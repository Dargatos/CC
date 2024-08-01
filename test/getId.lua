local peripherals = peripheral.getNames()
local turtleName = peripherals[1]  -- Assumes the first peripheral is the turtle
local id = peripheral.call(turtleName, "getID")
print(turtleName)
print("The ID of the other turtle is: " .. id)
