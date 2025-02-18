
local PROTOCOL = "Info"
local infoRelayHost = "InfoCollector"

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

function split(inputstr, sep)
    sep = sep or "%s"
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        local arg = str:match( "^%s*(.-)%s*$" )
        print("Found arg: "..arg)
        table.insert(t,arg) -- match: clears start and end whitespace
    end
    return t
end

function gatherInfo()
    print("Gathering...")
    settings.load()
    local infos = {}
    rednet.broadcast(PROTOCOL,"get")
    local event, id, message, protocol = os.pullEvent("rednet_message")
    if id and message then
        print(id,message)
        local args = split(message,",")
        if #args > 0 then                
            if args[1] == "packet" then
                if #args < 5 then print("Malformed packet. (#"..id..": "..message..")"); os.sleep(3); return; end
                local label = args[2]
                local id = label:gsub("%s+", "_")
                infos[id] = {
                    Label = label,
                    Value = args[3],
                    Prefix = args[4],
                    Suffix = args[5]
                }
                settings.set("app.InfoReceiver.info",infos)
                settings.save()
            end
        end
    end
end

function draw()
    settings.load()
    term.clear()
    term.setCursorPos(1,1)
    print("Infos:\n")
    local infos = settings.get("app.InfoReceiver.info",{})
    for _,v in pairs(infos) do
        print(" "..v.Label..": "..v.Prefix..v.Label..v.Suffix)
    end
end


while true do
    --draw()
    gatherInfo()
    os.sleep(1)
end