local List = {}
List.__index = List

function List:new(values)
    local obj = setmetatable({}, List)
    obj.xPos = values.xPos or 1
    obj.yPos = values.yPos or 1
    obj.width = values.width or 20
    obj.height = values.height or 10
    obj.monitor = values.monitor or term
    obj.bg = values.bg or colors.black
    obj.txColor = values.txColor or colors.white
    obj.hibgColor = values.hibgColor or colors.pink
    obj.hitextColor = values.hitextColor or colors.cyan
    obj.headers = values.headers or {"Name", "Amount"}  -- Separate headers
    obj.items = values.items or {}  -- List of row data { { "Item", "Count" } }
    obj.selectedRow = nil  -- Currently selected row
    obj.columnWidths = {} -- Stores the width of each column dynamically
    obj.altcolor = values.altcolor or colors.gray
    obj.onSelect = values.onSelect or nil  -- Callback function for selection
    obj:calculateColumnWidths() -- Calculate column widths dynamically

    return obj
end

function List:calculateColumnWidths()
    print("compu column width")
    self.columnWidths = {}

    -- Determine max width for each column
    for colIndex, header in ipairs(self.headers) do
        local maxWidth = #header
        for _, row in ipairs(self.items) do
            if row[colIndex] then
                -- Remove "minecraft:" or any prefix before ":"
                local strValue = tostring(row[colIndex]):gsub(".*:", "")
                maxWidth = math.max(maxWidth, #strValue)
            end
        end
        self.columnWidths[colIndex] = maxWidth + 2  -- Add spacing
    end
end

function List:draw()
    local mon = self.monitor
    mon.setBackgroundColor(self.bg)
    mon.setTextColor(self.txColor)

    -- Clear the area (reset screen in that range)
    for i = 0, self.height do
        mon.setCursorPos(self.xPos, self.yPos + i)
        mon.write(string.rep(" ", self.width))
    end

    -- Draw headers
    mon.setCursorPos(self.xPos, self.yPos)
    for i, header in ipairs(self.headers) do
        mon.write(header .. string.rep(" ", self.columnWidths[i] - #header))
    end

    -- Draw rows
    for rowIndex, row in ipairs(self.items) do

        mon.setCursorPos(self.xPos, self.yPos + rowIndex)
        if self.selectedRow == rowIndex then
            mon.setBackgroundColor(self.hibgColor)
            mon.setTextColor(self.hitextColor)
        elseif rowIndex % 2 == 0 then
            mon.setBackgroundColor(self.altcolor)
            mon.setTextColor(self.txColor)
        else
            mon.setBackgroundColor(self.bg)
            mon.setTextColor(self.txColor)
        end

        -- Draw each column value
        for colIndex, value in ipairs(row) do
            local strValue = tostring(value)
            local name = strValue:gsub(".*:", "")  -- Remove everything before and including ":"
            mon.write(name .. string.rep(" ", self.columnWidths[colIndex] - #name))
        end
    end

    mon.setBackgroundColor(colors.black)  -- Reset background
end

function List:update(values)
    -- Access the current object, which is already 'self'
    self:calculateColumnWidths()
    for k, v in pairs(values) do
        self[k] = v  -- Update the values of the current object
    end
    if self.autoUpdate == true then
        self:draw() 
    end
    return self  -- Return the updated object (useful for method chaining)
end

function List:updateRow(index, newValues)
    if self.items[index] then
        for colIndex, newValue in pairs(newValues) do
            self.items[index][colIndex] = newValue
        end
        self:calculateColumnWidths() -- Recalculate column sizes
        self:draw() -- Redraw list
    end
end

function List:updateCell(row, col, newValue)
    if self.items[row] and self.items[row][col] then
        self.items[row][col] = newValue
        self:calculateColumnWidths()
        self:draw()
    end
end

function List:isInside(px, py)
    return px >= self.xPos and px <= self.xPos + self.width
       and py >= self.yPos and py <= self.yPos + self.height
end

function List:selectRow(px, py)
    if not self:isInside(px, py) then return end

    local row = py - self.yPos
    if row > 0 and row <= #self.items then
        self.selectedRow = row
        self:draw()  -- Update display

        -- Trigger the onSelect callback if provided
        if self.onSelect then
            local selectedItem = self.items[row]
            self.onSelect(selectedItem, row)  -- Pass the selected item and row index
        end
    end
end

function List:handleTouch(x, y)
    local rowIndex = y - self.yPos  -- Adjust for list position

    if rowIndex >= 1 and rowIndex <= #self.items then
        print("List touch")
        self.selectedRow = rowIndex
        self:draw()  -- Redraw to highlight selected row

        -- Execute row command if available
        if type(self.items[rowIndex]) == "table" and self.items[rowIndex].command then
            self.items[rowIndex].command()
        end

        -- Trigger the onSelect callback if provided
        if self.onSelect then
            local selectedItem = self.items[rowIndex]
            self.onSelect(selectedItem, rowIndex)  -- Pass the selected item and row index
        end
    end
end


return List
