

local terminal = require("/terminal"):new()


local MAINMENU_OPTIONS = {
    "Shell",
    "Programs",
    "Update",
    "Download",
}

function handleMenu()
    repeat
        local resStr, resInd = terminal:promptOptions("",false,MAINMENU_OPTIONS,4)

        if resInd == 3 then
            terminal:clearMultiLines(4,terminal.size.y-3)
            local resStr,resInd = terminal:promptOptions("Are you sure?",false,{"&dYes","&eNo"},5)
            if resInd == 1 then
                shell.run("install")
            end
        end

    until resInd == 1
    terminal:reset()
    return
end

function drawLabels()
    while true do
        local info = "&7ID: "..os.getComputerID()
        if turtle ~= nil then
            info = info.."  FL: "..math.floor(turtle.getFuelLevel()/turtle.getFuelLimit()).."%"
        end
        info = info.."  &7Label: '"..os.getComputerLabel().."'"
        terminal:seperator("&7-",terminal.size.y-1)
        terminal:writeLine(terminal.size.y,info)
        terminal:seperator("&8=",1)
        terminal:writeLine(2," Phrawg&5OS")
        terminal:seperator("&8=",3)
        os.sleep(0.1)
    end
end

parallel.waitForAny(drawLabels,handleMenu)