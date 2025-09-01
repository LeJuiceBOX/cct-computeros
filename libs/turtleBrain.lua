-- 4YV4ewAY
local fileHelper = require("/fileHelper")

local FILE_HASMOVED = "/temp/mine_has_made_move.txt"
local MOVE_DELAY = 0.5

--=================================================================================================================
--// Enums
--=================================================================================================================

local module = {}
module.Dir = {
    N = 1,
    E = 2,
    S = 3,
    W = 4,
}

--=================================================================================================================
--// TurtleBrain
--=================================================================================================================

module.__index = module

function module:new(navDataSavePath)
	local self = setmetatable({}, module)

    self.CurrentDir = 1
	self.X = 0
    self.Y = 0
    self.Z = 0
	
    self.navSavePath = navDataSavePath or false

    self.navLast = false
    if self.navSavePath then
        self.navLast = string.gsub(navDataSavePath,".txt","_last.txt")
        fileHelper.setLines(FILE_HASMOVED,{"1"})
    end

    self.useToolForward = turtle.dig
	return self
end

--=================================================================================================================
--// Turtle Navigation
--=================================================================================================================

function module:forwardUntilBlock()
    self:setHasMoved(false)
    self:saveLastNav()
    if self.CurrentDir == module.Dir.N then
        self.Z = self.Z + 1
    elseif self.CurrentDir == module.Dir.S then
        self.Z = self.Z - 1
    elseif self.CurrentDir == module.Dir.E then
        self.X = self.X + 1
    elseif self.CurrentDir == module.Dir.W then
        self.X = self.X - 1
    end 
    self:saveNav()
    repeat until turtle.forward()
    os.sleep(MOVE_DELAY)
    self:setHasMoved(true)
end

function module:forceForward(times, ignoreTurts)
    ignoreTurts = ignoreTurts or false
    times = times or 1
    if times == 0 then return; end
    turtle.select(1)
    for i = 1, times do
        self:setHasMoved(false)
        self:saveLastNav()
        if self.CurrentDir == module.Dir.N then
            self.Z = self.Z + 1
        elseif self.CurrentDir == module.Dir.S then
            self.Z = self.Z - 1
        elseif self.CurrentDir == module.Dir.E then
            self.X = self.X + 1
        elseif self.CurrentDir == module.Dir.W then
            self.X = self.X - 1
        end
        self:saveNav()
                
        -- wait for no turtle
        if ignoreTurts == false then
            local isBlock,data = turtle.inspect() 
            if isBlock and string.find(data.name,"computercraft:turtle") then
                repeat os.sleep(0.25) until not turtle.inspect()
            end
        end
        
        repeat turtle.dig() until turtle.forward()
        os.sleep(MOVE_DELAY)
        self:setHasMoved(true)
    end
end

function module:forceUp(times,ignoreTurts)
    ignoreTurts = ignoreTurts or false
    times = times or 1
    if times == 0 then return; end
    turtle.select(1)
    for i = 1, times do
        self:setHasMoved(false)
        self:saveLastNav() 
        self.Y = self.Y + 1
        self:saveNav()

        -- wait for no turtle
        if ignoreTurts == false then
            local isBlock,data = turtle.inspectUp() 
            if isBlock and string.find(data.name,"computercraft:turtle") then
                repeat os.sleep(0.25) until not turtle.inspectUp()
            end
        end

        repeat turtle.digUp() until turtle.up()
        os.sleep(MOVE_DELAY)
        self:setHasMoved(true)
    end 
end

function module:forceDown(times,ignoreTurts)
    ignoreTurts = ignoreTurts or false
    times = times or 1
    if times == 0 then return; end
    turtle.select(1)
    for i = 1, times do 
        self:setHasMoved(false)
        self:saveLastNav()  
        self.Y = self.Y - 1
        self:saveNav()
                
        -- wait for no turtle
        if ignoreTurts == false then
            local isBlock,data = turtle.inspectDown() 
            if isBlock and string.find(data.name,"computercraft:turtle") then
                repeat os.sleep(0.25) until not turtle.inspectDown()
            end
        end
        
        repeat turtle.digDown() until turtle.down()
        os.sleep(MOVE_DELAY)
        self:setHasMoved(true)
    end 
end


function module:turnRight(times)
    times = times or 1
    if times == 0 then return; end
    for i = 1, times do
        self:setHasMoved(false)
        self:saveLastNav()
        self:_changeDir(1)
        self:saveNav()
        turtle.turnRight()
        os.sleep(MOVE_DELAY)
        self:setHasMoved(true)
    end
end



function module:turnLeft(times)
    times = times or 1
    if times == 0 then return; end
    for i = 1, times do
        self:setHasMoved(false)
        self:saveLastNav()
        self:_changeDir(-1)
        self:saveNav()
        turtle.turnLeft()
        os.sleep(MOVE_DELAY)
        self:setHasMoved(true)
    end
end

-- order: e.g {3,1,2} for z x y

function module:moveTo(x,y,z,order)
    order = order or {2,1,3}
    x = x or self.X
    y = y or self.Y
    z = z or self.Z
    local xDiff = self.X - x
    local yDiff = self.Y - y
    local zDiff = self.Z - z
    local xDir = (((getRelativeSide(self.X,x) > 0) and module.Dir.E) or module.Dir.W)
    local zDir = (((getRelativeSide(self.Z,z) > 0) and module.Dir.N) or module.Dir.S)
    local isAbove = (((getRelativeSide(self.Y,y) > 0) and true) or false)

    for _,axis in pairs(order) do
        if axis == 1 then -- MOVE X
            if xDiff ~= 0 then
                --print("XDir: "..xDir)   
                self:turnToFace(xDir)
                self:forceForward(math.abs(xDiff))
            end
        elseif axis == 2 then -- MOVE Y
            if isAbove then
                self:forceUp(math.abs(yDiff))
            else
                self:forceDown(math.abs(yDiff))
            end
        elseif axis == 3 then -- MOVE Z
            if zDiff ~= 0 then
                self:turnToFace(zDir)
                self:forceForward(math.abs(zDiff))
            end
        end
    end
end

function module:turnToFace(dir)
    assert(dir, "Dir is nil.")
    if dir == self.CurrentDir then return; end
    local turnTo = tonumber(dir)
    --print(self.CurrentDir)
    local diff = math.abs(turnTo - self.CurrentDir)
    if dir > self.CurrentDir then
        self:turnRight(diff)
    else
        self:turnLeft(diff)
    end
end

function module:getWorldPos()
    settings.load()
    local wx,wy,wz = settings.get("TurtleWorldOrigin",nil)
    if wx then
        return self.x+wx,self.y+wy,self.z+wz
    end
end

--=================================================================================================================
--// Turtle
--=================================================================================================================

function module:refuelAll()
    for i = 1,16 do
        turtle.select(i)
        turtle.refuel()
    end
    turtle.select(1)
end

function module:isInvFull(minFullSlots)
    minFullSlots = minFullSlots or 16
    if minFullSlots > 16 then 
        minFullSlots = 16
    elseif minFullSlots < 1 then
        minFullSlots = 1
    end

    for i = minFullSlots,1,-1 do
        turtle.select(i)
        if turtle.getItemCount() == 0 then
            turtle.select(1)
            return false
        end
    end
    turtle.select(1)
    return true
end

function module:predictFuelUsageTo(x,y,z) -- predicts the fuel usage to pos
    local blocks =
        (self.X - x) +
        (self.Y - y) +
        (self.Z - z)
    return (blocks)
end

function module:predictFuelUsage(x,y,z,x2,y2,z2)
    local blocks =
    (x - x2) +
    (y - y2) +
    (z - z2)
    return (blocks)
end

function module:hasEnoughFuel(blocksToTravel)
    return turtle.getFuelLevel() >= blocksToTravel
end

function module:getPos()
    return {self.X,self.Y,self.Z}
end

function module:emptyInventoryDown(ignoreSlot)
    ignoreSlot = ignoreSlot or -1
    for i = 1,16 do
        if i ~= ignoreSlot then
            turtle.select(i)
            turtle.dropDown()
        end
    end
    turtle.select(1)
end


--=================================================================================================================
--// Files
--=================================================================================================================

function module:deleteNav()
    if not self.navSavePath then return; end
    if fs.exists(self.navSavePath) then
        fs.delete(self.navSavePath)
    end
    if fs.exists(self.navLast) then
        fs.delete(self.navLast)
    end
    if fs.exists(FILE_HASMOVED) then
        fs.delete(FILE_HASMOVED)
    end
end

function module:loadNav(useLastNav)
    if self.navSavePath then
        if fs.exists(self.navSavePath) then
            useLastNav = useLastNav or false
            local x,y,z,dir
            if useLastNav then
                x,y,z,dir = table.unpack(fileHelper.getLines(self.navLast))
            else
                x,y,z,dir = table.unpack(fileHelper.getLines(self.navSavePath))
            end
            self.X = tonumber(x)
            self.Y = tonumber(y)
            self.Z = tonumber(z)
            self.CurrentDir = tonumber(dir)
            return
        end
    end
end

function module:saveNav()
    if self.navSavePath then
        fileHelper.setLines(self.navSavePath, {
            self.X,
            self.Y,
            self.Z,
            self.CurrentDir
        })
    end
end
-- COMBINE INTO ONE NAV FILE, PASTE THIS & MINE.LUA
function module:saveLastNav()
    if self.navSavePath then
        fileHelper.setLines(self.navLast, {
            self.X,
            self.Y,
            self.Z,
            self.CurrentDir
        })
    end
end

function module:setHasMoved(bool)
    local s
    if bool then
        s = "1"
    else
        s = "0"
    end
    fileHelper.setLines(FILE_HASMOVED,{s})
end

function module:getHasMoved()
    local n = fileHelper.getLines(FILE_HASMOVED)[1]
    return (n == 1)
end

--=================================================================================================================
--// Private
--=================================================================================================================

function module:_changeDir(inc)
    local pred = self.CurrentDir + inc
    if pred > module.Dir.W then
        pred = module.Dir.N
    elseif pred < 1 then
        pred = module.Dir.W
    end
    self.CurrentDir = pred
end

--=================================================================================================================
--// Local
--=================================================================================================================

function getRelativeSide(x1,x2)
    return ((x2 >= x1) and 1) or -1
end

return module