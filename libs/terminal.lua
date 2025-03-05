-- Kz2mdMyW
local module = {}
module.__index = module

module.mcColorSymbol = '§'
module.replaceSymbol = '&'
module.removeSymbol = 'Â'

module.ColorMap = {
    ["0"] = colors.white,
    ["1"] = colors.orange,
    ["2"] = colors.magenta,
    ["3"] = colors.lightBlue,
    ["4"] = colors.yellow,
    ["5"] = colors.lime,
    ["6"] = colors.pink,
    ["7"] = colors.gray,
    ["8"] = colors.lightGray,
    ["9"] = colors.cyan,
    ["a"] = colors.purple,
    ["b"] = colors.blue,
    ["c"] = colors.brown,
    ["d"] = colors.green,
    ["e"] = colors.red,
    ["f"] = colors.black,
}

--====================================================================================================
--// Terminal
--====================================================================================================

function module:new()
	local self = setmetatable({}, module)
    local tsx,tsy = term.getSize()
    self.output = term
    self.outputLine = 1
    self.canColor = term.isColor()
    self.size = {
        x = tsx,
        y = tsy
    }
	return self
end

function module:setOutput(t)
    self.output = t or term
    self.canColor = self.output.isColor()
    local tsx,tsy = self.output.getSize()
    self.size = {
        x = tsx,
        y = tsy
    }
end

function module:getComputerLabel()
    return string.gsub(os.getComputerLabel() or "Untitled",self.mcColorSymbol.."%w","")
end

--====================================================================================================
--// Complex writing
--====================================================================================================

function module:displayHeader(table,startLine)
    startLine = startLine or 1
    local line = 0
    for i,text in pairs(table) do
        line = startLine+(i-1)
        term.clearLine(line)
        term.setCursorPos(1,line)
        print(text)
    end
    term.setCursorPos(1,startLine+(#table))
end

function module:display(startLine,...)
    local cx,cy = term.getCursorPos() 
    startLine = startLine or cy
    local lines = {...}
    for i = 1, #lines do
        local y = (startLine+i)
        self:writeLine(y,lines[i])
    end
    term.setCursorPos(1,startLine+#lines+1)
end

function module:displayFromList(startLine,list)
    local cx,cy = term.getCursorPos() 
    startLine = startLine or cy
    for i = 1, #list do
        local y = (startLine+i)
        self:writeLine(y,list[i])
    end
    term.setCursorPos(1,startLine+#list+1)
end

function module:displayColumn(startLine,columnWidth,col1,col2)
    local w,h = term.getSize()
    local x,y = term.getCursorPos()
    columnWidth = columnWidth or w/2
    startLine = startLine or y
    for i, text in pairs(col1) do
        self:writeAt(1,startLine+(i-1),text)
    end
    for i, text in pairs(col2) do
        self:writeAt((w/2)-1,startLine+(i-1),text)
    end
end

function module:splitIntoColumns(startLine,columnWidth,list)
    local c1 = {}
    local c2 = {}
    for i = 1, #list do
        if i < #list/2 then
            table.insert(c1,list[i])
        else
            table.insert(c2,list[i])
        end
    end
    self:displayColumn(startLine,columnWidth,c1,c2)
end

--====================================================================================================
--// Basic text witing
--====================================================================================================

function module:setColor(color)
    if self.canColor == false then return; end
    self.output.setTextColor(color)
end
function module:setColorCode(code)
    if self.canColor == false then return; end
    for c,color in pairs(self.ColorMap) do
        if code == c then
            self.output.setTextColor(color)
        end
    end
end

function module:colorWrite(str)
    if str == nil then printError("String is nil"); return end
    local txt = {}
    local builtStr = ""
    local lastSymbolPos = 0
    self:setColor(colors.white)
    for i = 1, #str do
        local charBefore = str:sub(i-1, i-1)
        local char = str:sub(i, i)
        local charAfter = str:sub(i+1, i+1)
        if char == module.replaceSymbol and charBefore ~= "\\" and charAfter ~= " " then
            self.output.write(builtStr)
            builtStr = ""
            lastSymbolPos = i+1
            self:setColorCode(charAfter)
        elseif i ~= lastSymbolPos then
            builtStr = builtStr..char
        end
    end
    self.output.write(builtStr)
    self:setColor(colors.white)
end

function module:removeColorCodes(str)
    if str == nil then printError("String is nil"); return end
    local builtStr = ""
    for i = 1, #str do
        local charBefore = str:sub(i-1, i-1)
        local char = str:sub(i, i)
        local charAfter = str:sub(i+1, i+1)
        if charBefore ~= self.replaceSymbol and char ~= self.replaceSymbol  then
            builtStr = builtStr..char
        end
    end
    return builtStr
end

function module:writeLine(lineNumber,txt)
    if type(lineNumber) ~= "number" then printError("lineNumber is a string, did you forget to input line number?")return end
    txt = txt or ""
    self.output.setCursorPos(1,lineNumber)
    self.output.clearLine(lineNumber)
    self:colorWrite(txt)
    self.output.setCursorPos(1,lineNumber+1)
end

function module:writeAt(x,y,txt)
    if type(x) ~= "number" then printError("p1 must be a number.")return end
    if type(y) ~= "number" then printError("p1 must be a number.")return end
    txt = tostring(txt) or ""
    self.output.setCursorPos(x,y)
    self:colorWrite(txt)
    self.output.setCursorPos(1,y+1)
end

function module:write(txt)
    txt = txt or ""
    self:colorWrite(txt)
end

function module:print(txt)
    txt = txt or ""
    local _,y = self.output.getCursorPos()
    self.output.clearLine(y)
    self:writeLine(y,txt)
    self.output.setCursorPos(1,y+1)
end

function module:setOutputLine(lineNum)
    self.outputLine = lineNum
    term.setCursorPos(1,lineNum)
end

function module:reset()
    self.output.clear()
    self.output.setCursorPos(1,1)
end

--====================================================================================================
--// Prompts
--====================================================================================================

function module:prompt(promtText)
    self:print(tostring(promtText))
    self:write("> ")
    return io.read()
end

function module:promptNum(promptText)
    local res = self:prompt(promptText)
    return tonumber(res)
end

function module:promptBool(promptText)
    local res = self:promptNum(promptText)
    return (res == 1)
end

function module:promptConf(promptText,useOptions)
    useOptions = useOptions or false
    self:print(promptText)
    if useOptions then
        local _, res = self:promptOptions(nil,false,{"&dYes","&eNo"})
        return (res == 1)
    else
        while true do
            local k = self:waitForKey()
            if k == keys.enter then
                return true
            elseif k == keys.backspace then
                return false
            end
        end
    end
end

function module:promptFilePath(startDir,modifyMode,prompt)
    if startDir == nil then return; end
    if fs.isDir(startDir) == false then return; end
    modifyMode = modifyMode or false
    local lastHead = nil
    local head = startDir
    while true do
        self:reset()
        local file, result = self:promptFile(head,modifyMode,prompt,1)
        if result == self.PromptFileResult.GoUp then
            if head == lastHead or lastHead == nil then 
                self:print("&a\nExiting...")
                os.sleep(0.1)
                return nil
            end
            self:print("&a\nMoving up a directory...")
            head = lastHead
            os.sleep(0.1)
        elseif result == self.PromptFileResult.SelectedDirectory then
            if #fs.list(file) > 0 then
                lastHead = head
                head = file
            else
                if modifyMode then
                    self:modifyFile(file)
                else
                    self:print("&aChosen directory has no files.")
                    self:print("&aPlease select another one.")
                    os.sleep(1)
                end
            end
        elseif result == self.PromptFileResult.SelectedFile then
            if modifyMode then
                self:reset()
                self:modifyFile(file)
            else
                return file
            end
        end
    end
    self:reset()
end

module.PromptFileResult = {
    SelectedDirectory = 1,
    SelectedFile = 2,
    GoUp = 3,
    NoChildren = 4
}

function module:promptFile(startDir,allowFileModify,prompt,startLine)
    local _,y = self.output.getCursorPos()
    allowFileModify = allowFileModify or false
    local files = fs.list(startDir)
    -- color the directories
    for i,fName in pairs(files) do
        local fPath = startDir.."/"..fName
        if fs.isDir(fPath) then
            files[i] = "&4"..files[i]
        else
            files[i] = files[i]
        end
    end
    
    local resName,resInd = self:promptOptions(prompt or "Choose a file ~",true,files,startLine)
    if resInd == -1 then
        return nil, self.PromptFileResult.GoUp
    end
    local fn = self:removeColorCodes(files[resInd])
    local path = startDir.."/"..fn
    if fs.isDir(path) then
        return path, self.PromptFileResult.SelectedDirectory
    else
        return path, self.PromptFileResult.SelectedFile
    end
end

function module:promptOptions(promptMsg,allowCancel,optionsArray,startLine)
    local x,y = self.output.getCursorPos()
    startLine = startLine or y
    if optionsArray == nil then
        printError("Options array is nil.")
    end
    if #optionsArray < 1 then
        printError("Options array has no items.")
        return
    end
    allowCancel = allowCancel or false
    local selectedIndex = 1
    local selectedText
    repeat
        self.output.setCursorPos(1,startLine)
        if promptMsg then            
            self:print(promptMsg)
            self:print()
        end
        for i,v in pairs(optionsArray) do
            local ind = i
            if selectedIndex == ind then
                self:print("&3> "..v)
            else
                self:print(" "..v)
            end
        end
        local key = self:waitForKey()
        if key == 265 then -- up
            selectedIndex = selectedIndex - 1
            if selectedIndex < 1 then
                selectedIndex = #optionsArray
            end
        elseif key == 264 then -- down
            selectedIndex = selectedIndex + 1
            if selectedIndex > #optionsArray then
                selectedIndex = 1
            end
        elseif allowCancel and key == 259 then -- backspace (exit)
            return "", -1
        end
    until key == 257 -- enter
    return selectedText, selectedIndex
end

--====================================================================================================
--// Wait for keys
--====================================================================================================

function module:waitForKey()
    term.setCursorBlink(false)
    while true do
        local event, key, is_held = os.pullEvent("key")
        term.setCursorBlink(true)
        return key, is_held;
    end
end

function module:waitForNumberKey(max)
    max = max or 9
    while true do
        local keyCode = self:waitForKey()
        local num = self.getKeyCodeInt(keyCode)
        if num and num <= max then return num; end
    end
end

function module:pressAnyKeyToContinue()
    local x,y = term.getCursorPos()
    print("Press any key to continue...")    
    term.setCursorPos(0,0)
    self:waitForKey()
    term.setCursorPos(x,y)
end

--====================================================================================================
--// Prompts
--====================================================================================================

function module:modifyFile(filePath)
    if filePath == nil then
        self:reset()
        printError("Terminal:modifyFile requires a filepath.")
    end
    repeat
        self:reset()
        local resName, resInd = self:promptOptions(
            "File: '"..filePath.."'\n",
            true,
            {
                "Cancel",
                "Execute",
                "Edit",
                "Delete",
            }
        )
        if resInd == 2 then -- execute
            shell.run(filePath)
            return
        elseif resInd == 3 then -- edit
            shell.run("edit "..filePath)
        elseif resInd == 4 then -- delete
            self:reset()
            self:print("File: '"..filePath.."'")
            local _, resInd = self:promptOptions("Delete this file?",false,{"&dYes","&eNo"})
            if resInd == 1 then
                shell.run("delete "..filePath)
                return
            end
        end
    until resInd == 1 -- cancel
end

--====================================================================================================
--// Utils
--====================================================================================================

function module.formatInt(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

function module:getItemDisplayName(itemId)
    local str = string.gsub(itemId,".*:", "")
    str = string.gsub(str,"_"," ")
    str = string.gsub(str,"^%l", string.upper)
    return str
end

function module:mcColorize(text)
    local txt = string.gsub(text,module.replaceSymbol,module.mcColorSymbol)
    txt = string.gsub(txt,module.removeSymbol,"")
    return txt
end

function module.getKeyCodeInt(keycode)
    local c = keycode-48
    if c > 9 or c < 0 then return nil end
    return c
end

function module:seperator(char,lineNumber)
    local x,y = term.getCursorPos()
    lineNumber = lineNumber or y
    local s = ""
    for i = 1, self.size.x do
        s = s..tostring(char)
    end
    self:clearLine(lineNumber)
    self:writeLine(lineNumber)
end



return module