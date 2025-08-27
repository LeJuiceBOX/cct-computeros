local SEPERATOR = "======================================="
local BUCKET_ID = "minecraft:bucket"
local FUELBUCKET_ID = "minecraft:lava_bucket"


function MAIN()
    clear()
    welcomeMessage()
    untilSuccess(waitForBucket)
    clear()
    say(SEPERATOR)
    say("\nFueling up...\n")
    say(SEPERATOR)
    Refuel();
    clear()
    say(SEPERATOR)
    say("\nFinished.\n")
    say(SEPERATOR)
end

function clear() shell.run("clear"); end
function say(...) print(...); end

function untilSuccess(func,...)
    local s = false
    repeat s = func(...); until s;
end

function waitForBucket()
    turtle.select(1)
    local dat = turtle.getItemDetail()
    if not dat or dat.name ~= BUCKET_ID then say("Insert bucket in slot 1 to continue."); pause(); return false; end
    return true;
end

function pause() 
    print("\nPress ENTER to continue..."); 
    local pX,pY = term.getCursorPos()
    --term.setCursorPos(0,0);
    io.read();
    clear()
    --term.setCursorPos(1,1)
    welcomeMessage();
end

function Refuel(dir)
    local blocksMoved = 0
    repeat
        turtle.placeDown()
        turtle.select(1)
        local dat = turtle.getItemDetail()
        if dat and dat.name == FUELBUCKET_ID then
            turtle.refuel(1)
        end
		turtle.forward()
        blocksMoved = blocksMoved + 1
        print("Fuel: "..tostring(turtle.getFuelLevel()).."...")
    until turtle.getFuelLevel() >= turtle.getFuelLimit() - 100;
    repeat
        turtle.back() 
        blocksMoved = blocksMoved - 1
    until blocksMoved == 0
end

function welcomeMessage()
    say(SEPERATOR)
    say("Welcome to Turtle Refill!")
    say(SEPERATOR)
end

function isValidDir(txt)
    local t = string.upper(txt)
    return not ( (t=="TOP") or (t=="BOTTOM") or (t=="LEFT") or (t=="RIGHT") or (t=="FRONT") or (t=="BACK") );
end

MAIN()
