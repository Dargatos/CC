local githubUser = "Dargatos"  -- Change to your GitHub username
local githubRepo = "CC"  -- Change to your repository name
local branch = "main"        -- Change if using a different branch
local baseURL = "https://api.github.com/repos/" .. githubUser .. "/" .. githubRepo .. "/contents/lib?ref=" .. branch

local function downloadFile(path, downloadURL)
    local filePath = "tuff/" .. path:gsub("^tuff/", "") -- Keep correct structure
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

print("Fetching all files in lib/... from GitHub")
fetchContents(baseURL)
print("Installation complete!")
