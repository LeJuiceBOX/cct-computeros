
local SETTINGS_INFOS = "app.InfoReceiver.info"
local PROTOCOL = "Info"

local packet = require("/packet")
local terminal = require("/terminal"):new()

term.clear()
term.setCursorPos(1,1)
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
peripheral.find("modem", rednet.open)


function gatherInfo()
    --print("Gathering...")
    settings.load()
    local infos = settings.get(SETTINGS_INFOS,{})
    rednet.broadcast(PROTOCOL,"get")
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
                print("Updated")
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


while true do
    gatherInfo()
    draw()
    os.sleep(0.25)
end