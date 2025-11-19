---@diagnostic disable: undefined-global

local baseURL = "https://raw.githubusercontent.com/girafficCrunch/CC-Tweaked-scripts/refs/heads/main/"
local files = {
    "quarry.lua",
    "trackPos.lua"
}

for i, file in ipairs(files) do
    local fullURL = baseURL .. file
    local outputName = file:match("([^/]+)$") -- just filename, not folders
    print("Downloading "..file.."...")
    shell.run("wget", "-f", fullURL, outputName)
end

print("All files downloaded!")