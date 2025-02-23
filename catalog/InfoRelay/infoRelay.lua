local COLLECT_INSTRUCTION_TEMPLATE = "https://raw.githubusercontent.com/LeJuiceBOX/cct-computeros/refs/heads/main/catalog/InfoRelay/_templateCollectionInstructions.txt"
local COLLECT_INSTRUCTION_SCRIPT = "os/programFiles/InfoRelay/collect_instructions.lua"
local COLLECT_INSTRUCTION_REQ = "/os.programFiles.InfoRelay.collect_instructions"
local SETTINGS = "app.InfoRelay"

local packet = require("/packet")
local terminal = require("/terminal"):new()

fs.makeDir("os/programFiles/InfoRelay")
settings.load()

local firstTime
local label
local prefix
local suffix

local collect_func


local modem = peripheral.find("modem")
if not modem.isWireless() then
    print("Modem must be wireless, exiting...")
    os.sleep(2)
    term.clear()
    term.setCursorPos(1,1)
    return
end

settings.load()
peripheral.find("modem", rednet.open)

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
        terminal:print("&8Recomendation: >1")
        terminal:print()
        collectInterval = terminal:promptNum("Enter an integer:")
        --
        terminal:reset()
        terminal:print("Input a label for this data.")
        terminal:print("It will look like this in the InfoReceiver:")
        terminal:print("&8<label>: <prefix><value><suffix>")
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

local lastSend = 0

function collect()
    while true do
        shell.run(COLLECT_INSTRUCTION_SCRIPT)
        local value = settings.get("app.InfoRelay.value","&eerror")
        terminal:reset()
        terminal:print("InfoRelay is active!")
        terminal:print("Label: "..label)
        terminal:print("Value: "..tostring(value))
        terminal:print("Last send: "..tostring(os.clock()-lastSend))
        terminal:print()
        terminal:print("Press any key for the menu.")
        rednet.broadcast(packet.compile("packet",label,value,prefix,suffix),"Info")
        lastSend = os.clock()
        os.sleep(collectInterval)
    end
end


function main()
    settings.load()
    loadSettings()
    terminal:reset()
    if firstTime then setup() end
    if fs.exists(COLLECT_INSTRUCTION_SCRIPT) == false then
        shell.run("wget "..COLLECT_INSTRUCTION_TEMPLATE.." "..COLLECT_INSTRUCTION_SCRIPT)
        print("created file")
    end
    --collect_func = require(COLLECT_INSTRUCTION_REQ)
    while true do
        parallel.waitForAny(collect, function()
            terminal:pressAnyKeyToContinue() 
        end)
        terminal:reset()
        terminal:print("Relay paused.")
        local opts = {
            "Edit collection script",
            "Redo setup",
            "Unpause",
            "Exit"
        }
        local resStr, resInd = terminal:promptOptions("What would you like to do?",false,opts,4)
        if resInd == 1 then 
            shell.run("edit "..COLLECT_INSTRUCTION_SCRIPT)
            --collect_func = require(COLLECT_INSTRUCTION_REQ)
        elseif resInd == 2 then
            setup()
            loadSettings()
        elseif resInd == 4 then
            break
        end
    end
    terminal:reset()
    rednet.close()
end

main()