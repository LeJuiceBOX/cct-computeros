local terminal = require("/terminal"):new()

terminal:reset()
terminal:seperator("&8=",1)
terminal:writeLine(2," Phrawg&5OS  &7- Catalog")
terminal:seperator("&8=",3)
terminal:print()
terminal:print("These are various useful scripts i've made.")

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