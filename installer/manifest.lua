
settings.load()
settings.set("os.manifest",{
    {
        Name = "terminal.lua",
        Git = "LeJuiceBOX/cct-computeros/refs/heads/main/libs/terminal.lua",
        Paste = nil
    },

    {
        Name = "packet.lua",
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

    {
        Name = "install.lua",
        Git = "LeJuiceBOX/cct-computeros/refs/heads/main/installer/install.lua",
        Paste = nil
    },
    
    {
        Name = "computer/1/os/.system/task_name_computer.lua",
        Git = "",
        Paste = "",
    },

})
settings.save()