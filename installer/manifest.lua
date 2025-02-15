
settings.load()
settings.set("os.manifest",{

    {
        Name = "os/cmds/gitget.lua",
        Git = "LeJuiceBOX/cct-computeros/refs/heads/main/computer/lib/terminal.lua",
        Paste = nil
    },

    {
        Name = "libs/terminal.lua",
        Git = "LeJuiceBOX/cct-computeros/refs/heads/main/computer/lib/terminal.lua",
        Paste = nil
    },

    {
        Name = "os/main.lua",
        Git = "LeJuiceBOX/cct-computeros/refs/heads/main/computer/os/main.lua",
        Paste = nil
    },

    {
        Name = "startup.lua",
        Git = "LeJuiceBOX/cct-computeros/refs/heads/main/computer/startup.lua",
        Paste = nil
    },

})
settings.save()