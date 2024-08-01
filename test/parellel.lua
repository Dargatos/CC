mon = peripheral.find("monitor")
local Number = 0

local function prepareMonitor()
    mon.clear()
    mon.setBackgroundColor(colors.black)
    mon.setCursorPos(5, 2)
    mon.setBackgroundColor(colors.cyan)
    mon.write(" ")
    mon.setCursorPos(5, 12)
    mon.write(" ")
    mon.setCursorPos(5, 22)
    mon.write(" ")
    mon.setBackgroundColor(colors.black)
end

local function refresh()
    while true do
        mon.setCursorPos(1, 1)
        mon.write(Number)
        Number = Number + 1
        print("refreshed")
        sleep(1)  -- Yielding to prevent "too long without yielding" error
        coroutine.yield()
    end
end

local function monTouchHandler()
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")
        if x == 10 and y == 10 then
            Number = 111
        elseif x == 10 and y == 20 then
            Number = Number + 10
        elseif x == 10 and y == 30 then
            Number = Number + 10
        end
        print("Touch event handled")
        coroutine.yield()
    end
end

local function main()
    prepareMonitor()
    parallel.waitForAny(refresh,monTouchHandler)
    print("Started both routines")

end

main()
