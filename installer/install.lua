term.clear()
shell.run("gitget temp_manifest.lua LeJuiceBOX/cct-computeros/refs/heads/main/gitget.lua")
shell.run("temp_manifest.lua")

settings.load()
local files = settings.get("os.manifest",{})

if #files == 0 then print("No files in 'os.manifest', failed to install.") os.sleep(2) return; end

print("Downloading "..tostring(#files).." files...")

for i, v in pairs(files) do
    if v.Git ~= nil then
        shell.run("getgit "..tostring(v.Name).." "..tostring(v.Git))
    elseif v.Paste ~= nil then
        shell.run("pastebin get "..tostring(v.Paste).." "..tostring(v.Name))
    end
end

print("Finished installing ComputerOS... Enjoy!")
shell.run("reboot")

