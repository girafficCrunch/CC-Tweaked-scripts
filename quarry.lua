-- This program is designed to run in CraftOS via the current release of CC: Tweaked
---@diagnostic disable: undefined-global
local trackPos = require("trackPos")

-- ================================================================
-- Program Arguments
-- ================================================================
local args = {...}

for _, arg in ipairs(args) do
    if arg == "-h" or arg == "--help" then
        print("Usage: quarry [diameter] [depth] [startPos]")
        print("  diameter  : width of the quarry (default 5)")
        print("  depth     : layers to dig or -1 for bedrock (default -1)")
        print("  startPos  : bottomLeft | bottomRight (default bottomLeft)")
        return
    end
end

local diameter = tonumber(args[1]) or 5
local depth = tonumber(args[2]) or -1
local startPos = args[3] or "bottomLeft"

if diameter < 1 then
    print("diameter must be at least 1")
    return
end

if depth == 0 then
    print("depth cannot be 0")
    print("depth must be a positive number or -1 for bedrock")
    return
elseif depth < -1 then
    print("depth must be a positive number or -1 for bedrock")
    return
end

if startPos ~= "bottomLeft" and startPos ~= "bottomRight" then
    print("startPos must be bottomLeft or bottomRight")
    return
end

--Request fuel
while turtle.getFuelLevel() < 500 do
    turtle.select(1)
    print("Current fuel: " .. turtle.getFuelLevel() .. "/500")
    print("Add fuel, then press Enter to continue (or type 'q' to quit):")
    local resp = read()
    if resp and type(resp) == "string" and resp:lower() == "q" then
        return
    end
    turtle.refuel()
end

--Request inventory
while type(peripheral.wrap("back")) ~= "table" do
    print("No inventory detected.")
    print("Place an inventory behind the turtle, then press Enter.")
    print("Or type 'd' and Enter to dump items on the ground.")
    local resp = read()
    if resp == "d" then
        break
    end
end

--Ask for confirmation before continuing else cancel
do
    print("Quarry size: "..diameter.."x"..diameter)
    print("StartingPos: "..startPos)
    print("Target depth: "..depth)
    print("")
    print("Proceed? Enter 'y' to continue...")
    local resp = read()
    if resp == "y" then
        print("Diggy hole!")
        sleep(1)
    else
        print("Quarry canceled!")
        sleep(1)
        print("rebooting...")
        sleep(2)
---@diagnostic disable-next-line: undefined-field
        os.reboot()
    end
end

-- ================================================================
-- Core Quarry Logic
-- ================================================================
local blockCount = 0
local currentDepth = 0

-- Detect if the block directly below is bedrock
local function isBedrockDown()
    local ok, data = turtle.inspectDown()
    if data.name == "minecraft:bedrock" then
        depth = math.abs(trackPos.position.y)
    end
end

--Send turtle home to deposit items
local function pitstop()
    local checkpoint = {
        x = trackPos.position.x,
        y = trackPos.position.y,
        z = trackPos.position.z,
        d = trackPos.position.d,
    }
    trackPos.home()
    for _ = 1, 16 do
        if turtle.getItemCount(_) > 0 then
            turtle.select(_)
            turtle.drop()
        end
    end
    turtle.select(1)
    while turtle.getFuelLevel() < 500 do
        print("Need fuel!")
        print("press Enter to continue...")
        read()
        turtle.refuel()
    end
    trackPos.moveTo(checkpoint)
end

local function refuel()
    if turtle.getFuelLevel() < 1000 then
        for _ = 1, 16 do
            if turtle.getItemCount(_) > 0 then
                turtle.select(_)
                turtle.refuel()
                if turtle.getFuelLevel() > 5000 then
                    break
                end
            end
        end
        turtle.select(1)
        if turtle.getFuelLevel() < 500 then
            pitstop()
        end
    end
end

local function checkInventory()
    if turtle.getItemCount(16) > 0 then
        pitstop()
    end
end

--Send turtle to dig in a straight line (for use with diameter)
local function digMove(quantity)
    for _ = 1, quantity or 1 do
        if turtle.detect() then
            turtle.dig()
        end
        trackPos.moveForward()
        checkInventory()
    end
end


local function digLevel()
    for line = 1, diameter - 1 do
        digMove(diameter - 1)
        if line % 2 == 1 then
            trackPos.turnRight(1)
            digMove()
            trackPos.turnRight(1)
        else
            trackPos.turnLeft(1)
            digMove()
            trackPos.turnLeft(1)
        end
    end
    digMove(diameter - 1)
    trackPos.turnRight((diameter % 2) + 1) --if even columns turn once, if odd turn twice
    refuel()
end

local function descend()
    if turtle.detectDown() then
        turtle.digDown()
    end
    trackPos.moveDown()
    checkInventory()
end

local function quarry()
    turtle.select(1)
    if startPos == "bottomRight" then
        trackPos.turnLeft()
    end
    digLevel()
    while depth ~= math.abs(trackPos.position.y) do
        descend()
        digLevel()
    end
end

local function updateScreen()
    if depth > 0 then
        local targetDepth = depth
    else local targetDepth = "bedrock"
    end
    while true do
        term.clear()
        term.setCursorPos(1,1)
        print("Turtle Stats:")
        print("-------------")
        print("Blocks mined:", blockCount)
        print("Fuel level:", turtle.getFuelLevel())
        print("Depth:", currentDepth,"/", targetDepth)
        sleep(1)
    end
end

parallel.waitForAny(quarry, updateScreen)