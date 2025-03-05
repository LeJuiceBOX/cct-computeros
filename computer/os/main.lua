
local gitLib = require("/gitLib")
local terminal = require("/terminal"):new()


local MAINMENU_OPTIONS = {
    "Shell",
    "Programs",
    "Update",
    "Download",
    "Catalog",
}

local doDrawLabels = true

function main()
    terminal:reset()
    if os.getComputerLabel() == nil then
        shell.run("os/.system/task_name_computer.lua")
    end
    parallel.waitForAny(drawLabels,handleMenu)
end

function handleMenu()
    repeat
        local resStr, resInd = terminal:promptOptions("",false,MAINMENU_OPTIONS,4)

        if resInd == 3 then
            terminal:clearMultiLines(4,terminal.size.y-3)
            local resStr,resInd = terminal:promptOptions("Are you sure?",false,{"&dYes","&eNo"},5)
            if resInd == 1 then
                doDrawLabels = false
                terminal:reset()
                shell.run("install")
                return
            end
        elseif resInd == 5 then
            terminal:clearMultiLines(4,terminal.size.y-3)
            local dirs, err = gitLib.getRepoDirs("LeJuiceBOX","cct-computeros","catalog")
            local names = {}
            for i,v in pairs(dirs or {}) do
                names[i] = v.Name
            end
            table.insert(names,"&eBack")

            local resStr, resInd = terminal:promptOptions("Choose a download ~",false,names or {"No dirs..?"},4)
            if err == "Failed to connect to GitHub" then
                terminal:clearMultiLines(4,terminal.size.y-3)
                terminal:writeLine(4,"GitHub rate-limited you, slow down!")
                os.sleep(2)
            end

            if resInd == #names then
                -- leave blank so it loops back to menu
            end
            
        end

    until resInd == 1
    terminal:reset()
    terminal:seperator("&8=",1)
    terminal:writeLine(2," Phrawg&5OS  &7- Terminal")
    terminal:seperator("&8=",3)
    terminal:print("Use the 'back' cmd to return to the main menu.")
    shell.setAlias("back", "os/main.lua")
    term.setCursorPos(1,6)
    return
end

function drawLabels()
    while true do
        if doDrawLabels then
            local info = "&7| ID: &8"..os.getComputerID().."&7"
            info = info.." | &7Label: '&8"..(os.getComputerLabel() or "").."&7'"
            if turtle ~= nil then
                info = info.." | FL: &8"..math.floor((turtle.getFuelLevel()/turtle.getFuelLimit())*100).."%&7"
            end
            terminal:seperator("&7-",terminal.size.y-1)
            terminal:writeLine(terminal.size.y,info)
            terminal:seperator("&8=",1)
            terminal:writeLine(2," Phrawg&5OS")
            terminal:seperator("&8=",3)
        end
        os.sleep(0.1)
    end
end

main()