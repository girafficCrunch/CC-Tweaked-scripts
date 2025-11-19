---@diagnostic disable: undefined-global

local baseURL = "https://raw.githubusercontent.com/girafficCrunch/CC-Tweaked-scripts/refs/heads/main/"
local listURL = baseURL .. "index.txt"

--Source index of scripts
local h = http.get(listURL)
if not h then
    print("Failed to fetch file list!")
    return
end

local files = {}
for line in h.readAll():gmatch("[^\r\n]+") do
  table.insert(files, line)
end
h.close()

--Download Scipts
for i, file in ipairs(files) do
    local fullURL = baseURL .. file
    local outputName = file:match("([^/]+)$") -- just filename, not folders
    print("Downloading "..file.."...")
    shell.run("wget", "-f", fullURL, outputName)
end

print("All files downloaded!")