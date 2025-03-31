
function DrawButtonList(monitor,list)
    local btnDistance = list.btnDistance
    local label = list.label
    local xPos = list.xPos
    local yPos = list.yPos
    local headcolor = list.headcolor or colors.green
    local tc = list.textcolor or colors.white
    local bg = list.backgroundcolor or colors.black
    local anchor = list.anchor or "right"
    local yoffset = list.yoffset or 1
    local kind = list.kind or false

    if not label then
        yoffset = 0
    end

    -- calculates longest label
    if not btnDistance then
        btnDistance = 0
        for i, item in pairs(list.buttons) do
            if #item.name > btnDistance then
                btnDistance = #item.name
            end
        end
        btnDistance = btnDistance + 1 
        list["btnDistance"] = btnDistance
    end

    monitor.setCursorPos(xPos,yPos)
    monitor.setBackgroundColor(bg)
    monitor.setTextColor(headcolor)

    if label then 
        monitor.write(label)
        yPos = yPos + yoffset
    else
        yPos = yPos -1
    end

    monitor.setTextColor(tc)
    for i, btn in pairs(list.buttons) do

        if kind == "itself" then
            monitor.setBackgroundColor(colors.gray)
        else
            monitor.setBackgroundColor(bg)
        end

        monitor.setCursorPos(xPos,yPos + i)
        monitor.write(btn.name)
        monitor.setBackgroundColor(colors.green)
        monitor.setCursorPos(xPos + btnDistance,yPos + i)
        
        -- Saves position of placed button in list.
        list.buttons[i]["x"] = xPos + btnDistance
        list.buttons[i]["y"] = yPos + i
        
        if kind == "x" then
            monitor.write("x")
        elseif kind == "o" then
            monitor.write("o")
        elseif not kind then
            monitor.write(" ")
        end
    end
end

function DrawButton()
    
end