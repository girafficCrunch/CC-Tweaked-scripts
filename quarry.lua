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
        print("Quarry canceled")
        os.exit()
    end
end

-- ================================================================
-- Core Quarry Logic
-- ================================================================
--Send turtle home to deposit items
local function pitstop()
    local checkpoint = trackPos.position
    trackPos.home()
    for _ = 1, 16 do
        turtle.select(_)
        turtle.drop()
    end
    trackPos.moveTo(checkpoint)
end

local function digMove(quantity)
    for _ = 1, quantity do
        if turtle.detect() then
            turtle.dig()
        end
        trackPos.moveForward()
    end
end

-- Detect if the block directly below is bedrock
local function isBedrockDown()
    local ok, data = turtle.inspectDown()
    if data.name == "minecraft:bedrock" then
        depth = math.abs(trackPos.position.y)
    end
end