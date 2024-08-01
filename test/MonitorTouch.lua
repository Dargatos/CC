-- Define a button and its position
local button = {
    label = "Click Me!",
    x = 5,
    y = 5,
    width = 10,
    height = 3
}

-- Function to draw the button
local function drawButton(monitor, button)
    monitor.setBackgroundColor(colors.cyan)
    monitor.setTextColor(colors.black)
    for i = 0, button.height - 1 do
        monitor.setCursorPos(button.x, button.y + i)
        monitor.write(string.rep(" ", button.width))
    end
    local textX = button.x + math.floor((button.width - #button.label) / 2)
    local textY = button.y + math.floor(button.height / 2)
    print(string.rep(" ", button.width))
    monitor.setCursorPos(textX, textY)
    monitor.write(button.label)
end

local function drawmybtn(monitor, button)
    monitor.setBackgroundColor(colors.cyan)
    monitor.setTextColor(colors.black)
    btnX = #button.label + 1
    monitor.setCursorPos(button.x + btnX, button.y)
    monitor.write(" ")
    monitor.setCursorPos(button.x, button.y)
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.cyan)
    monitor.write(button.label)
end
-- Function to clear the monitor
local function clearMonitor(monitor)
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    monitor.setCursorPos(1, 1)
end

-- Function to handle touch events
local function handleTouchEvent(monitor, button, event, side, x, y)
    if x >= button.x and x < button.x + button.width and y >= button.y and y < button.y + button.height then
        -- Button was clicked
        monitor.setBackgroundColor(colors.green)
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.write("Button Clicked!")
        sleep(2)
        clearMonitor(monitor)
        drawmybtn(monitor, button)
    end
end

-- Main function
local function main()
    -- Find the monitor
    local monitor = peripheral.find("monitor")
    if not monitor then
        print("No monitor found")
        return
    end

    -- Set the monitor text scale and clear it
    monitor.setTextScale(0.5)
    clearMonitor(monitor)

    -- Draw the button
    drawmybtn(monitor, button)

    -- Event loop to handle touch events
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")
        print(event .. " " ..side ..  " " .. x ..  " " .. y)

        monitor.write(event, side, x, y)
        handleTouchEvent(monitor, button, event, side, x, y)
    end
end

-- Run the main function
main()
