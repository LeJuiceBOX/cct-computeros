
local SETTINGS_INFOS = "app.InfoReceiver.info"
local PROTOCOL = "Info"

local packet = require("/packet")
local terminal = require("/terminal"):new()

terminal:reset()
print("Loading...")

local modem = peripheral.find("modem")
if not modem.isWireless() then
    print("Modem must be wireless, exiting...")
    os.sleep(2)
    term.clear()
    term.setCursorPos(1,1)
    return
end

settings.load()
local infos = settings.get(SETTINGS_INFOS,{})

settings.load()
peripheral.find("modem", rednet.open)


function listen()
    --print("Gathering...")
    while true do
        local event, id, message, protocol = os.pullEvent("rednet_message")
        if id and message then
            --print(id,message)
            local args = packet.parse(tostring(message))
            if #args > 0 then                
                if args[1] == "packet" then
                    if #args < 3 then print("Malformed packet. (#"..id..": "..message..")"); os.sleep(3); return; end
                    local pre = args[4] or ""
                    local suf = args[5] or ""
                    local id = args[2]:gsub("%s+", "_")
                    infos[id] = {
                        Label = args[2],
                        Value = args[3],
                        Prefix = pre,
                        Suffix = suf
                    }
                    settings.set(SETTINGS_INFOS,infos)
                    settings.save()
                end
            end
        end
    end
end

function draw()
    settings.load()
    terminal:reset()
    terminal:print("Infos:\n")
    local infos = settings.get("app.InfoReceiver.info",{})
    for _,v in pairs(infos) do
        terminal:print(" "..v.Label..": "..v.Prefix..v.Value..v.Suffix)
    end
end



parallel.waitForAny(listen,function()
    repeat
        parallel.waitForAny(function()    
            while true do
                draw()
                os.sleep(0.25)
            end
        end,function()
            terminal:print()
            terminal:print()
            terminal:pressAnyKeyToContinue()
        end)
        terminal:reset()
        local opts = {"Back","Push to monitor","Exit"}
        local res, resInd = terminal:promptOptions("What would you like to do?",false,opts,3)
        if resInd == 2 then
            terminal:setOutput(peripheral.find("monitor"))
        end
    until res == "Exit"
end)