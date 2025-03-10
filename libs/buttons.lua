local module = {}
module.__index = module

function module:new(monitorSide)
	local self = setmetatable({}, module)
    self.output = peripheral.wrap(monitorSide) or term
    self.buttons = {}
	return self
end

function  module:newButton(x,y,txt,textColor,backgroundColor,onClick)
    textColor = textColor or self.output.getTextColor()
    backgroundColor = backgroundColor or self.output.getBackgroundColor()
    table.insert(self.buttons,{
        x = x,
        y = y,
        text = txt,
        textColor = textColor,
        backgroundColor = backgroundColor,
        w = #txt or 1,
        h = 1,
        onClick = onClick
    })
end

function module:handleClickedButtons(clickX,clickY)
    for i,button in pairs(self.buttons) do
        if clickX >= button.x and clickX <= button.x+button.w then
            if clickY >= button.y and clickY <= button.y+button.h then
                button.onClick()
                return button
            end
        end
    end
    return
end

function module:drawButtons()
    local prevTc = self.output.getTextColor()
    local prevBgc = self.output.getBackgroundColor()
    for i,button in pairs(self.buttons) do
        local textColor = button.textColor
        local backgroundColor = button.backgroundColor
        self.output.setBackgroundColor(backgroundColor)
        self.output.setTextColor(textColor)
        self.output.setCursorPos(button.x,button.y)
        self.output.write(button.text)
    end
    self.output.setBackgroundColor(prevBgc)
    self.output.setTextColor(prevTc)
end

return module