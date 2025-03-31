local function getMonitorStats(monitor)
    monX , monY = monitor.getSize()
    return monX, monY
end

-- Draws a button with its label in the center
local function drawInlineTextButton(monitor, button)
    local label = button.label or "Button" 
    local width = button.width or #button.label
    local height = button.height or 1
    local xPos = button.x
    local yPos = button.y
    local backgroundcolor = button.backcolor or 256 -- lightgray
    local textcolor = button.textcolor or 1 --white

    monitor.setBackgroundColor(backgroundcolor)
    for i = 0, height -1 do
        monitor.setCursorPos(xPos,yPos + i)
        monitor.write(string.rep(" ", width))
    end
    monitor.setTextColor(textcolor)
    --monitor.setBackgroundColor(backgroundcolor)
    labelPosx = xPos + (width - #label) / 2
    labelPosy = yPos + (height - 1) / 2
    monitor.setCursorPos(labelPosx, labelPosy)
    monitor.write(label)
end

-- Draws a list of buttons on the monitor the label is on the left and the buttone on the right of the label
local function drawButtonList(monitor,list)
    local label = list.label
    local xPos = list.xPos
    local yPos = list.yPos
    local headcolor = list.headcolor or colors.green
    local tc = list.textcolor or colors.white
    local bg = list.backgroundcolor or colors.black
    local anchor = list.anchor or "right"
    local offset = list.offset or 1
    local yoffset = list.yoffset or 1

    if not label then
        yoffset = 0
    end

    -- calculates longest label
    local btnDistance = 0
    for i, name in pairs(list.buttons) do
        if #name > btnDistance then
            btnDistance = #name
        end
    end

    monitor.setCursorPos(xPos,yPos)
    monitor.setBackgroundColor(bg)
    monitor.setTextColor(headcolor)
    monitor.write(label)

    monitor.setTextColor(tc)
    for i, name in pairs(list.buttons) do
        monitor.setBackgroundColor(bg)
        monitor.setCursorPos(xPos,yPos + yoffset + i)
        monitor.write(name)
        monitor.setBackgroundColor(colors.green)
        monitor.setCursorPos(xPos + btnDistance + offset ,yPos + 1 + i)
        monitor.write(" ")
    end
end
