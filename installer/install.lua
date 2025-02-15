--paste: qt30y8cE
term.clear()

shell.run("pastebin get Y1TpxWrH os/cmds/getgit.lua")
shell.setAlias("getgit","os/cmds/getgit.lua")

shell.run("getgit temp_manifest.lua LeJuiceBOX/cct-computeros/refs/heads/main/installer/manifest.lua")
os.sleep(0.25)
shell.run("temp_manifest.lua")
fs.delete("temp_manifest.lua")

settings.load()
local files = settings.get("os.manifest",{})

if #files == 0 then print("No files in 'os.manifest', failed to install.") os.sleep(2) return; end


for i, v in pairs(files) do
    term.clear()
    term.setCursorPos(1,1)
    print("Downloading "..tostring(#files).." files...\n\n")
    if v.Git ~= nil then
        shell.run("getgit "..tostring(v.Name).." "..tostring(v.Git))
    elseif v.Paste ~= nil then
        shell.run("pastebin get "..tostring(v.Paste).." "..tostring(v.Name))
    end
end

print("Finished installing ComputerOS... Enjoy!")
shell.run("reboot")

