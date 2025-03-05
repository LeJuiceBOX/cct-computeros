

local terminal = require("/terminal"):new()


local MAINMENU_OPTIONS = {
    "Shell",
    "Programs",
    "Update",
    "Download",
}

function menuSelect()
    repeat
        terminal:promptOptions("",false,MAINMENU_OPTIONS,4)
    until false
end

function drawLabels()
    while true do
        terminal:reset()
        terminal:seperator("&8=",1)
        terminal:print(" Phrawg&5OS")
        terminal:seperator("&8=",3)
        local info = "&7ID: "..os.getComputerID()
        if turtle ~= nil then
            info = info.."  FL: "..math.floor(turtle.getFuelLevel()/turtle.getFuelLimit()).."%"
        end
        info = info.."  &7Label: '"..os.getComputerLabel().."'"
        terminal:seperator("&7-",terminal.size.y-1)
        terminal:writeLine(terminal.size.y,info)
    end
end

parallel.waitForAny(drawLabels,menuSelect)