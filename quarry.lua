-- This program is designed to run in CraftOS via the current release of CC: Tweaked

local trackPos = require("trackPos")
---@diagnostic disable: undefined-global
--[[
Quarry -diameter - depth -startingPosition
    diameter default = 5
    depth default = hit bedrock
    startingPosition default = bottomLeft

Checks
    has fuel?
    has deposit location?

Ask for confirmation
    "Quarry will be 5x5, starting from bottom left"
    "depth will be..."
    "resources will be dumped in the the open"
    "Confirm Y/N"

Functions
    quarry
    digLevel - the pattern of going down a level

]]

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

while turtle.getFuelLevel() < 500 do
    print("Add fuel, then press Enter to continue (or type 'q' to quit):")
    local resp = read()
    if resp and type(resp) == "string" and resp:lower() == "q" then
        return
    end
end