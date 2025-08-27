-- 0DAspFKK

local cmdArgs = table.pack(...)

local Params = {
    Width = nil,
    Height = nil,
    Depth = nil,
    StartX = nil,
    StartDepth = nil,
    DepositMode = nil,
}

local DepoMode = {
    RunHome = 1,
    LeaveChest = 2,
    EnderChest = 3,
    Discard = 4
}

local Dir = {
    N = 1,
    E = 2,
    S = 3,
    W = 4
}

local FILE_PARAMS_DATA = "/temp/current_mine_params.txt"
local FILE_NAV_DATA = "/temp/mine_nav_data.txt"

local Brain = require("/turtleBrain"):new(FILE_NAV_DATA)
local Terminal = require("/terminal"):new()
local mineVolume = 0
local isResuming = false
local depositedResources = {}

--=====================================================================================

function Main()
    if #cmdArgs > 0 then
        Params.Width = tonumber(cmdArgs[1])
        Params.Height = tonumber(cmdArgs[2])
        Params.Depth = tonumber(cmdArgs[3])
        Params.StartX = tonumber(cmdArgs[4])
        Params.StartDepth = tonumber(cmdArgs[5])
        Params.DepositMode = tonumber(cmdArgs[6])
    else
        local success = GetParams()
        if success == false then return; end
    end
    Brain.X = Params.StartX
    Terminal:reset()
    Terminal:print("Starting work!")
    local start = 1
    if isResuming then
        Brain:moveTo(Params.StartX,0,Brain.Z-1)
        Brain:turnToFace(Dir.N)
    else
        Brain:forceForward(Params.StartDepth)
    end
    print("starting now!!!")
    --// Mining
    for i = start, Params.Depth do
        local success, msg = mineLayer()
        if success == false then
            Terminal:reset()
            Terminal:print(msg)
            break
        end
    end
    depositItems()
    --// Finish
    Brain:moveTo(Params.StartX,1,0,{1,2,3})
    repeat
        Brain:deleteNav()
        Terminal:reset()
        Terminal:print("Turtle finished job.")
        Terminal:print()   
        local resName, resInd = Terminal:promptOptions("&1What do you want to do?",false,{
            "Exit",
            "View Info",
            "View Mined Resources"
        })
        if resInd == 3 then
            local yPos = 4
            local sorted = {}
            for name,ct in pairs(depositedResources) do
                table.insert(sorted,{name,ct})
            end
            table.sort(sorted, function(a, b) return a[2] > b[2] end)
            repeat  
                Terminal:reset()
                Terminal.output.setCursorPos(1,yPos)
                for i, data in pairs(sorted) do
                    local dispName = Terminal:getItemDisplayName(data[1])
                    local halfScreen = math.ceil(Terminal.size.x/2)
                    local str = dispName.."&8"
                    for i = 1, halfScreen-#dispName do
                        str = str.."."
                    end
                    Terminal:print(str.."&8x&4"..tostring(data[2]))
                end
                Terminal:writeLine(1,"&1[Backspace] - exit.")
                Terminal:writeLine(2,"&1[ArrowKeys] - scroll.")
                Terminal:writeLine(3,"")
                local key = Terminal:waitForKey()
                if key == 265 then -- up
                    yPos = yPos + 1
                elseif key == 264 then -- down
                    yPos = yPos - 1
                end
            until key == 259 -- backspace 
            Terminal:reset()
        end
    until resInd == 1
    Terminal:reset()
    -- clean up
    if fs.exists(FILE_PARAMS_DATA) then
        fs.delete(FILE_PARAMS_DATA)
    end
end

function GetParams()
    if fs.exists(FILE_NAV_DATA) then
        Terminal:reset()
        Terminal:print("&eAlert!")
        Terminal:print("This turtle shutdown half-way through")
        Terminal:print("most recent job.")
        Terminal:print()
        Terminal:print("&8This is possibly due to the turtle:")
        Terminal:print("&8breaking, shutting down, exploring an")
        Terminal:print("&8unloaded chunk, or the server shutdown.")
        Terminal:print()
        local res = Terminal:promptConf("&1Do you want to resume?",true)
        if res then
            Brain:loadNav(Brain:getHasMoved())
            Params.Width = tonumber(w)
            Params.Height = tonumber(h)
            Params.Depth = tonumber(d)
            Params.StartX = tonumber(startX)
            Params.StartDepth = tonumber(start)
            Params.DepositMode = tonumber(mode)
            isResuming = true
            return true -- continue
        else
            Brain:deleteNav()
            if fs.exists(FILE_PARAMS_DATA) then
                fs.delete(FILE_PARAMS_DATA)
            end
        end
    end
    repeat
        Params = {
            Width = nil,
            Height = nil,
            Depth = nil,
            StartX = nil,
            StartDepth = nil,
            DepositMode = nil,
        }
        Terminal:reset()
        Params.Width = Terminal:promptNum("Input block width:")
        Params.Height = Terminal:promptNum("Input block height:")
        Params.Depth = Terminal:promptNum("Input block depth:")
        Params.StartX = Terminal:promptNum("Input starting X: (leave blank for none)") or 0
        Params.StartDepth = Terminal:promptNum("Input starting Z: (leave blank for none)") or 0
    until Terminal:promptConf("Continue with these parameters?",true)
    repeat
        Terminal:reset()
        local menu = {
            "Return Home",
            "Leave Chests",
            "Enderchest",
            "Discard",
        }
        local modeName,mode = Terminal:promptOptions("Select a deposit mode:",false,menu)
        Terminal:reset() 
        if mode == DepoMode.RunHome then
            Terminal:display(nil,
                "Return Home:",
                "Turtle will return to origin to",
                "deposit its items.",
                ""
            )    
        elseif mode == DepoMode.LeaveChest then
            Terminal:display(nil,
                "Leave Chests:",
                "Turtle will place chests when its inventory",
                "fills up and deposits the items into it.",
                "NOTE: Uses multiple chests."
            )  
        elseif mode == DepoMode.EnderChest then
            Terminal:display(nil,
                "Enderchest:",
                "Turtle will place an ender chest and deposit",
                "its inventory into it. Turtle will break the EC",
                "and continue forth when inventory is deposited.",
                "NOTE: Ender chest must always be empty.",
                ""
            )  
        elseif mode == DepoMode.Discard then
            Terminal:display(nil,
                "Discard:",
                "Throw any items mined on to the ground.",
                ""
            )
        end
        --Terminal:pressAnyKeyToContinue()
        local res = Terminal:promptConf("&1Confirm selection? &8('"..menu[mode].."')",true)
        if res then Params.DepositMode = mode end
    until res
    Terminal:reset()
    mineVolume = Params.Width * Params.Height * Params.Depth
    --// Check if we have enough fuel for this job
    if Brain:hasEnoughFuel(mineVolume) then
        reset()
        print("Preparing to mine "..mineVolume.." blocks.")
        os.sleep(0.5)        
    else
        Terminal:print("There isn't enough fuel to complete") 
        Terminal:print("this job.")
        Terminal:print("")
        Terminal:print("Current Fuel: &e"..turtle.getFuelLevel()) 
        Terminal:print("Required Fuel: &d"..mineVolume)
        Terminal:print("")
        local res = Terminal:promptConf("Continue anyway?",true)
        if res == false then return false; end
    end
    --// Confirm certain requirments for desired mode
    if Params.DepositMode == DepoMode.LeaveChest then
        Terminal:reset()
        local predChests = math.ceil(mineVolume/1728)

        print(
            "Make sure a container block is placed in slot 1 of the turtle.\n"..
            "Without it, you will lose all your items.\n"..
            "(You'll need about "..predChests.." containers [ADD x2, POOR ESITIMATE])\n\n"
        )
        Terminal:pressAnyKeyToContinue()
        Terminal:reset()
    elseif Params.DepositMode == DepoMode.EnderChest then
        Terminal:reset()
        print(
            "Make sure an EnderChest, or something of the sort is placed in slot 1 of the turtle.\n"..
            "Without it, you will lose all your items.\n\n"
        )
        Terminal:pressAnyKeyToContinue()
        Terminal:reset()
    end
    Terminal:reset()
    -- save data to file
    local paramLines = {
        Params.Width,
        Params.Height,
        Params.Depth,
        Params.StartX,
        Params.StartDepth,
        Params.DepositMode
    }
    return true;
end

--=====================================================================================

function mineLayer()
    --// check if we have fuel for this layer
    local roundTrip = getRoundTripCost()
    local homeTrip = Brain:predictFuelUsageTo(0,0,0)
    if Brain:hasEnoughFuel(getLayerFuelCost()) == false then return false,"Not enough fuel to mine the next layer.\n(has: "..turtle.getFuelLevel()..", needed: "..homeTrip + getLayerFuelCost()..")"; end
    --// Move into layer to mine
    Brain:turnToFace(Dir.N)
    Brain:forceForward()
    if Params.Height == 1 and Params.Width == 1 then return true; end
    --// Mine rows until finished
    while Brain.Y <= Params.Height-1 do
        local mod = Brain.Y % 2
        if mod <= 0 then -- if we odd
            Brain:turnToFace(Dir.E)
            Brain:forceForward(Params.Width-1)
            if Brain:isInvFull() then depositItems(true) end
        elseif mod > 0  then -- if we even
            Brain:turnToFace(Dir.W)
            Brain:forceForward(Params.Width-1)
            if Brain:isInvFull() then depositItems(true) end
        end
        if Brain.Y == Params.Height-1 then break; end
        Brain:forceUp()
    end
    moveToGroundY()
    --// Reorientate afterwards
    if Brain.X == Params.Width-1 then -- if we are on the far end of X
        Brain:turnToFace(Dir.W)
        Brain:forceForward(Params.Width-1)
    end
    Terminal:reset()
    Terminal:print("Current Progress:")
    Terminal:print(Brain.Z.." out of "..Params.Depth.." layers completed.")
    return true
end

function depositItems(doReturn)
    doReturn = doReturn or false
    local lastPos = Brain:getPos()
    local lastDir = Brain.CurrentDir

    if Params.DepositMode == DepoMode.RunHome then        
        Brain:moveTo(0,0,0)
        logDepositItems()
        Brain:emptyInventoryDown()
        if doReturn then
            if Brain:hasEnoughFuel(table.unpack(lastPos)) == false then
                print("Not enough fuel to continue mining, staying at home.")
                return
            end
            Brain:moveTo(table.unpack(lastPos))
            Brain:turnToFace(lastDir)
        end

    elseif Params.DepositMode == DepoMode.LeaveChest then
        -- leave chest
        moveToGroundY()
        turtle.digDown()
        turtle.select(1)
        turtle.placeDown()
        logDepositItems(1)
        Brain:emptyInventoryDown(1)
        -- go back
        Brain:moveTo(table.unpack(lastPos))
        Brain:turnToFace(lastDir)
    elseif Params.DepositMode == DepoMode.EnderChest then
        -- leave ender chest
        turtle.digDown()
        turtle.select(1)
        turtle.placeDown()
        logDepositItems(1)
        Brain:emptyInventoryDown(1)
        turtle.select(1)
        turtle.digDown()
    elseif Params.DepositMode == DepoMode.Discard then
        logDepositItems()
        Brain:emptyInventoryDown()
    end
end

--=====================================================================================

function logDepositItems(ignoreSlot)
    ignoreSlot = ignoreSlot or -1
    for i = 1, 16 do
        if i ~= ignoreSlot then
            --turtle.select(i)
            local itemData = turtle.getItemDetail(i)
            if itemData then
                local added = false
                for name,val in pairs(depositedResources) do
                    if name == itemData.name then
                        depositedResources[name] = depositedResources[name] + itemData.count
                        added = true
                    end
                end
                if added == false then
                    depositedResources[itemData.name] = itemData.count
                end
            end
        end
    end
end

function moveToGroundY()
    Brain:moveTo(nil,0,nil)
end

function promtBool(text)
    local res = promtNum(text)
    return (res == 1)
end

function promtNum(text)
    local res = promt(text)
    return tonumber(res)
end

function promt(text)
    reset()
    print(tostring(text))
    term.write("> ")
    return io.read()
end

function repeatFunc(times,func)
    for i = 1, times do
        func()
    end
end

function reset()
    term.clear()
    term.setCursorPos(1,1)
end

function getRoundTripCost()
    local home = {0,0,0}
    local current = Brain:getPos()
    return Brain:predictFuelUsageTo(0,0,0) 
    + Brain:predictFuelUsage(0,0,0,current[1],current[2],current[3])
end

function getLayerFuelCost()
    return (Params.Width*Params.Height)
end

function writeParams(...)
    local p = {...}
    return "W: "..(p[1] or "?")..", H: "..(p[2] or "?")..", D: "..(p[3] or "?")
end

function clamp(num,min,max)
    if num > max then
        return max;
    elseif num < min then
        return min
    end
    return num
end
--=====================================================================================

Main()