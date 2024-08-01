mon = peripheral.find("monitor")
local Number = 0


local function prepareMonitor()
    mon.clear()
    mon.setBackgroundColor(colors.black)
    mon.setBackgroundColor(colors.cyan)
    mon.setCursorPos(5,2)
    mon.write(" ")
    mon.setCursorPos(5,12)
    mon.write(" ")
    mon.setCursorPos(5,22)
    mon.write(" ")

    mon.setBackgroundColor(colors.black)
end

local function refresh()
    while true do
        mon.setCursorPos(1,1)
        mon.write(Number)
        sleep(1) -- id dont get anyting printed behind that why 
        Number = Number + 1
        print("refreshed")
        coroutine.yield()
    end
    print("Stopping refres")
end

local function monTouchHandler()
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")
        if x == 10  and y == 10 then
            Number = 111
        elseif x == 10 and y == 20 then
            Number = Number + 10
        elseif x == 10 and y == 30 then
            Number = Number + 10
        end
        sleep(1) 
        print("Touch event handled")
        coroutine.yield()
    end
    print("Stopping touch")
end

local function main()
    prepareMonitor()

    local co_refresh = coroutine.create(refresh)
    local touchHandler = coroutine.create(monTouchHandler)

    print("Started both routines")
    while true do
        coroutine.resume(co_refresh)
        coroutine.resume(touchHandler)
    end
    

    local success_refresh, err_refresh = pcall(coroutine.resume, co_refresh)
    local success_touch, err_touch = pcall(coroutine.resume, touchHandler)

    if not success_refresh then
        print("Error in refresh coroutine:", err_refresh)
    end

    if not success_touch then
        print("Error in touchHandler coroutine:", err_touch)
    end

end
main()