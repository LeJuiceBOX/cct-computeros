
settings.load()
settings.set("os.manifest",{

    {
        Name = "os/cmds/gitget.lua",
        Git = "LeJuiceBOX/cct-computeros/refs/heads/main/computer/os/cmds/gitget.lua",
        Paste = nil
    },

    {
        Name = "/terminal.lua",
        Git = "LeJuiceBOX/cct-computeros/refs/heads/main/libs/terminal.lua",
        Paste = nil
    },

    {
        Name = "/packet.lua",
        Git = "LeJuiceBOX/cct-computeros/refs/heads/main/libs/packet.lua",
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