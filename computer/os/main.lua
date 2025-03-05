

local terminal = require("/terminal"):new()


local MAINMENU_OPTIONS = {
    "Shell",
    "Programs",
    "Update",
    "Download",
}

while true do
    terminal:reset()
    terminal:makeSeperator("&8=")
    terminal:print(" Phrawg&lOS")
    terminal:print(" Label: '"..os.getComputerLabel().."'")
    terminal:seperator("&8=")
    local info = "&7ID: "..os.getComputerID()
    if turtle ~= nil then
        info = info.."  FL: "..turtle.getFuelLevel()/turtle.getFuelLimit()
    end
    terminal:seperator("&7-",terminal.size.y-1)
    terminal:writeLine(terminal.size.y,info)
    terminal:promptOptions("",false,MAINMENU_OPTIONS,4)
end