--package.path = package.path .. ";./tuff/components/?.lua"
package.path = ";./tuff/components/?.lua" .. package.path
local Frame = require("frame")
local Touch_handler = require("touch_handler")

local tuff = {}

tuff.frames = {}

function tuff.Frame(values)
    local frame = Frame:new(values)
    table.insert(tuff.frames, frame)
    return frame
end

function tuff.render(frame)
    if frame then
        frame:draw()
    else

        for _, frame in ipairs(tuff.frames) do
            frame:draw()
        end
    end
end

function tuff.run()
    print("Nothing here yet")
end

function tuff.touch()
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")
        --print("Touched at:", x, y, "on", side)

        for _, frame in ipairs(tuff.frames) do 
            for _, child in ipairs(frame.children) do
                if child:isInside(x, y) then
                    if child.handleTouch then
                        print("handletouch found")
                        child:handleTouch(x, y) -- Delegate to component-specific function
                    elseif child.command then
                        child.command()
                    end
                end
            end
        end
    end
end

function tuff.clearAll()
    local monitors = {}

    -- Loop through all peripherals
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "monitor" then
            table.insert(monitors, peripheral.wrap(name))
        end
    end

    for _, mon in ipairs(monitors) do
        mon.setBackgroundColor(colors.black)
        mon.clear()
    end
end

return tuff