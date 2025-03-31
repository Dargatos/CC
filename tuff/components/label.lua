local Label = {}
Label.__index = Label

function Label:draw()
    local mon = self.parent and self.parent.monitor or self.monitor -- sets Monitor to parent monitor when it has a parent otherwise just the set monitor
    mon.setCursorPos(self.xPos, self.yPos)
    mon.setTextColor(self.txColor or colors.gray)
    mon.setBackgroundColor(self.bg or colors.blue)
    mon.write(self.text)
end

function Label:new(values)
    local obj = setmetatable({}, Label)
    obj.height = values.height or 1
    obj.width  = values.width or #values.text

    obj.autoUpadte = true

    for k, v in pairs(values) do
        obj[k] = v
    end
    
    return obj
end

function Label:update(values)
    -- Access the current object, which is already 'self'
    for k, v in pairs(values) do
        self[k] = v  -- Update the values of the current object
    end
    if self.autoUpadte == true then
        self:draw()
    end
    return self  -- Return the updated object (useful for method chaining)
end

function Label:isInside(px, py)

    return px >= self.xPos and px <= self.xPos + self.width and py >= self.yPos and py <= self.yPos + self.height -1
end

function  Label:hover()
    local mon = self.monitor
    mon.setBackgroundColor(self.hoverColor)

end

function  Label:highlight()
    local mon = self.monitor
    mon.setCursorPos(self.xPos, self.yPos)
    mon.setTextColor(self.hitextColor or self.textColor)
    mon.setBackgroundColor(self.hibgColor or self.bg)
end

return Label