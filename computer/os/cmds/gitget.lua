--==================================================================================================================================
--// Name: GitGet
--// Desc: Works like the pastebin command but for github raw.
--// Date: 2/15/25
--==================================================================================================================================
--paste: TFwdaR7G

local GUC = "https://raw.githubusercontent.com/"

local args = {...}

if #args < 3 then    
    print("gitget <mode> <link> <fileName>")
    print("\n<mode>\nType: string\nDesc: get or run")
    print("\n<link>\nType: string\nDesc: File location.")
    print("\n<fileName>\nType: string\nDesc: Everything after 'https://raw.githubusercontent.com/'")
    return
end

local mode = args[1]
local fileName = args[2]
local gitLink = args[3]

local gitHttp = http.get(GUC..gitLink)
local code = ""

function download(fn,link)
    print("\nDownloading code from github...")
    print("File Name: "..fileName)
    print()

    if gitHttp then
        print("Success!\n")
        code = gitHttp.readAll()
    else
        print("Download failed.")
        return
    end

    print("Writing to file...")
    local file = fs.open(fileName,"w")
    file.write(code)
    file.close()
end

function getFileNameNoExt(filePath)
    -- Get the base name of the file (without directory path)
    local baseName = filePath:match("([^/\\]+)$")
    -- Remove the file extension
    local nameWithoutExtension = baseName:match("^(.-)%.%w+$") or baseName
    return nameWithoutExtension
end
  

if mode == "get" then
    download(fileName,gitLink)
    print("Complete.")
elseif mode == "run" then
    local n = "gg_temp_"..getFileNameNoExt(fileName)..".lua"
    download(n,gitLink)
    os.sleep(0.1)
    shell.run(n)
    fs.delete(n)
else
    term.clear()
    term.setCursorPos(1,1)
    print("Mode unrecognized. Only accepts 'get' or 'run'. (got '"..tostring(mode).."')")
    print("Press ENTER to continue...")
    io.read()
end

