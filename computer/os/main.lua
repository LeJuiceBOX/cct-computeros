

local terminal = require("/terminal"):new()


local MAINMENU_OPTIONS = {
    "Shell",
    "Programs",
    "Update",
    "Download",
}

while true do
    terminal:reset()
    terminal:makeSeperator("=")
    terminal:print(" PhrawgOS")
    terminal:makeSeperator("=")
    local info = "Label: "..os.getComputerLabel()..", ID: "..os.getComputerID()
    if turtle ~= nil then
        info = info..", FL: "..turtle.getFuelLevel()/turtle.getFuelLimit()
    end
    term.setCursorPos(1,terminal.size.y-1)
    terminal:makeSeperator("=")
    terminal:writeLine(terminal.size.y,info)
    terminal:promptOptions("",false,MAINMENU_OPTIONS,4)
end