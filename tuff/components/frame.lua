local Frame = {}
Frame.__index = Frame

function Frame:new(values)
    local obj = setmetatable({},Frame)
    obj.children = {}

    obj.monitor = values.monitor or peripheral.find("monitor")
    obj.bgColor = values.bgColor or colors.gray

    return obj
end
function Frame:addChild(child)
    table.insert(self.children, child)
end

function Frame:addComponent(values)
    local componentType = require(values.type)
    local component = componentType:new(values)
    component.parent = self
    self:addChild(component)
    return component
end

function Frame:draw()
    self.monitor.setBackgroundColor(self.bgColor)
    self.monitor.clear()

    for _, child in ipairs(self.children) do
        if child.draw then
            child:draw()
        else
            print("Warning: A child does not have a 'draw' method.")
        end
    end
end

return Frame