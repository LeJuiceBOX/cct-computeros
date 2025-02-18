--=========================================================================================================================================
--// Desc: Installs computeros onto a computer or turtle.
--// Date: 2/15/25
--=========================================================================================================================================

-- setup getgit
term.clear()
term.setCursorPos(1,1)
if fs.exists("os/cmds/getgit.lua") then fs.delete("os/cmds/getgit.lua") end
shell.run("pastebin get Y1TpxWrH os/cmds/getgit.lua")
shell.setAlias("getgit","os/cmds/getgit.lua")
os.sleep(0.25)
-- pastebin manifest and run it
shell.run("wget run https://raw.githubusercontent.com/LeJuiceBOX/cct-computeros/refs/heads/main/installer/manifest.lua")

-- load settings set from manifest
settings.load()
local files = settings.get("os.manifest",{})

if #files == 0 then print("No files in 'os.manifest', failed to install.") os.sleep(2) return; end

-- download files
for i, v in pairs(files) do
    term.clear()
    term.setCursorPos(1,1)
    print("Downloading file "..tostring(i).." of "..tostring(#files).."...")
    print("Name: "..v.Name)
    print("\n\n")
    if fs.exists(v.Name) then fs.delete(v.Name); end
    if v.Git ~= nil then
        shell.run("wget https://raw.githubusercontent.com/"..v.Git.." "..v.Name)
    elseif v.Paste ~= nil then
        shell.run("pastebin get "..tostring(v.Paste).." "..tostring(v.Name))
    end
    os.sleep(0.65)
end
os.sleep(.25)
term.clear()
term.setCursorPos(1,1)
print("Finished installing ComputerOS... Enjoy!")
shell.run("reboot")

