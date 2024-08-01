rednet.open("back")
mon = peripheral.find("monitor")
local prot = "Stating_prot"
while true do
    local id, message, protocal =  rednet.receive()

    print(id)
    print(message)
    print(protocal)

    if protocal == prot then
        rednet.send(9,message)
        local line = 1
        local messages = {}
        mon.setCursorPos(1,1)
        mon.clear()
        mon.setTextScale(2)
        print(message)
        mon.write(message)
    end
   --table.insert(messages, message)
   --for i, count in ipairs(messages)
   --
   --    mon.setCursoPos(1,i)
   --    mon.write(message)
   --line = line +1
   
   
end