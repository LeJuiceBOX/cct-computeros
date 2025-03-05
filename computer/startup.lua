settings.load()
local autoExecPath = settings.get("os.autoExecPath","")

term.clear()
if autoExecPath ~= "" then
    if fs.exists(autoExecPath) then
        shell.run(autoExecPath)
    else
        print("File doesnt exist.\nPress enter...")
        io.read()
    end
end
shell.run("os/main.lua")