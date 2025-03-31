local githubUser = "Dargatos"  -- Change this to your GitHub username
local githubRepo = "CC"  -- Change this to your repo name
local branch = "main"        -- Change if using a different branch
local baseURL = "https://api.github.com/repos/" .. githubUser .. "/" .. githubRepo .. "/contents/"

local targetFolder = "CC2/"  -- This is where all files will be downloaded
fs.makeDir(targetFolder)
local function downloadFile(path, downloadURL)
    local filePath = targetFolder .. path:gsub("^lib/", "") -- Replace "lib/" with "tuff/"
    local folder = fs.getDir(filePath)

    if not fs.exists(folder) then
        fs.makeDir(folder)
    end

    print("Downloading: " .. filePath)
    shell.run("wget", downloadURL, filePath)
end

local function fetchContents(url)
    local response = http.get(url)
    if not response then
        print("Failed to fetch file list from GitHub!")
        return nil
    end

    local content = response.readAll()
    response.close()

    local data = textutils.unserializeJSON(content)
    if not data then
        print("Failed to parse JSON!")
        return nil
    end

    for _, item in ipairs(data) do
        if item.type == "file" then
            downloadFile(item.path, item.download_url)
        elseif item.type == "dir" then
            fetchContents(item.url) -- Recursively fetch subfolders
        end
    end
end

print("Fetching all files from GitHub into 'tuff/'")
fs.makeDir(targetFolder) -- Ensure the folder exists
fetchContents(baseURL)
print("Installation complete!")
