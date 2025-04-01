local Button = {}
Button.__index = Button


function Button:draw()
    local mon = self.parent and self.parent.monitor or self.monitor -- sets Monitor to parent monitor when it has a parent otherwise just the set monitor

    mon.setCursorPos(self.xPos, self.yPos)
    mon.setBackgroundColor(self.bgColor or colors.gray)
    width = math.max(self.width or 3, #self.text or 0)
    for i = 0, self.height - 1 or 1 do
        mon.setCursorPos(self.xPos, self.yPos + i)
        mon.write(string.rep(" ",width))
    end
    mon.setTextColor(self.txColor or colors.white)
    mon.setBackgroundColor(self.bgColor or colors.gray)
    mon.setCursorPos(self.xPos + (self.width) / 2 - #self.text / 2, self.yPos + ((self.height -1) / 2))
    mon.write(self.text)
end

function Button:new(values)
    local obj = setmetatable({}, Button)

    for k, v in pairs(values) do
        obj[k] = v
    end

    obj.height = values.height or 3
    obj.width = math.max(values.width or 3, #values.text + 2)
    obj.isActive = false
    obj.zIndex = obj.zIndex or 0
    obj.autoUpdate = values.autoUpdate or true
    return obj
end

function Button:update(values)
    -- Access the current object, which is already 'self'
    for k, v in pairs(values) do
        self[k] = v  -- Update the values of the current object
    end
    if self.autoUpadte == true then
        self:draw()
    end
    return self  -- Return the updated object (useful for method chaining)
end

function Button:isInside(px, py)
    -- Retruns if px py is inside area of button 
    return px >= self.xPos and px <= self.xPos + self.width and py >= self.yPos and py <= self.yPos + self.height -1
end

function Button:handleClick(px, py)
    if self:isInside(px, py) then
        print("Button clicked: " .. self.text)
    end
end

return Button