local function setAsStartup(scriptName)
    
    local startupScript = [[
    shell.run("]] .. scriptName .. [[")
    ]]
        local file = fs.open("startup", "w")
        file.write(startupScript)
        file.close()
        print("Script set as startup.")
end
setAsStartup(shell.getRunningProgram())
