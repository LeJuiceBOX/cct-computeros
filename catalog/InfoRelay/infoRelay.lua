
local SETTINGS = "app.InfoRelay"

local packet = require("/packet")
local terminal = require("/terminal"):new()

settings.load()

local firstTime
local label
local prefix
local suffix


function loadSettings()
    firstTime = settings.get(SETTINGS..".firstTime",true)
    label = settings.get(SETTINGS..".label",true)
    prefix = settings.get(SETTINGS..".prefix","")
    suffix = settings.get(SETTINGS..".suffix","")
end

function setup()
    repeat
        terminal:reset()
        terminal:print("Input your prefered data collection interval (sec)")
        terminal:print("Recomendation: >1")
        terminal:print()
        collectInterval = terminal:promptNum("Enter an integer:")
        --
        terminal:reset()
        terminal:print("Input a label for this data.")
        terminal:print("It will look like this in the InfoReceiver:")
        terminal:print("<label>: <prefix><value><suffix>")
        terminal:print()
        label = terminal:prompt("Enter text:")
        --
        terminal:reset()
        terminal:print("Input a prefix for this data.")
        terminal:print()
        prefix = terminal:prompt("Enter text:")
        --
        terminal:reset()
        terminal:print("Input a suffix for this data.")
        terminal:print()
        suffix = terminal:prompt("Enter text:")
        --
        terminal:reset()
        terminal:print("Collect interval: &c"..tostring(collectInterval))
        terminal:print("Label: &c"..label)
        terminal:print("Prefix: &c"..prefix)
        terminal:print("Suffix: &c"..suffix)
        terminal:print()
    until terminal:promptConf("Does everything look correct?",true)
    settings.set(SETTINGS..".interval",collectInterval)
    settings.set(SETTINGS..".label",label)
    settings.set(SETTINGS..".prefix",prefix)
    settings.set(SETTINGS..".suffix",suffix)
    settings.set(SETTINGS..".firstTime",false)
    settings.save()
    terminal:reset()
end

function options()
    terminal:reset()
    terminal:print("InfoRelay paused.")

    local opts = {
        "Edit collection script",
        "Unpause",
        "Exit"
    }
    terminal:promptOptions("What would you like to do?",false,opts,5)
end

function collect()
    local value = ""
    while true do
        terminal:reset()
        terminal:print("InfoRelay is active!")
        terminal:print("Label: "..label)
        terminal:print("Value: "..value)
        terminal:print()
        os.sleep(collectInterval)
    end
end


function main()
    settings.load()
    loadSettings()
    terminal:reset()
    if firstTime then setup() end
    while true do
        parallel.waitForAny(collect, function()
            terminal:pressAnyKeyToContinue()
        end)
        terminal:reset()
        termianl:print("Relay paused.")
        local opts = {
            "Edit collection script",
            "Unpause",
            "Exit"
        }
        local resStr, resInd = terminal:promptOptions("What would you like to do?",false,opts,4)
        if resInd == 1 then 
            shell.run("edit os/programFiles/InfoRelay/collect_instructions.lua")
        elseif resInd == 3 then
            break
        end
    end
end

main()