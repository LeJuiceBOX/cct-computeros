local terminal = require("/terminal"):new()

local str
terminal:reset()
terminal:seperator("&8=",1)
terminal:writeLine(2," Phrawg&5OS  &7- Setup - Set label")
terminal:seperator("&8=",3)
terminal:print()
repeat
    terminal:clearMultiLines(4,terminal.size.y)
    term.setCursorPos(1,5)
    str = terminal:prompt("Please name this computer to continue ~")
    term.setCursorPos(1,5)
    terminal:print("Are you sure you want to name your computer...")
until terminal:promptConf("   '"..str.."&0'?",true)
os.setComputerLabel(str)
