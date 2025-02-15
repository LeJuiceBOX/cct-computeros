--==================================================================================================================================
--// Name: GitGet
--// Desc: Works like the pastebin command but for github raw.
--// Date: 2/15/25
--==================================================================================================================================
--paste: TFwdaR7G

local GUC = "https://raw.githubusercontent.com/"

local args = {...}

if #args < 2 then    
    print("gitget <file> <link>")
    print("\n<file>\nType: string\nDesc: File location.")
    print("\n<link>\nType: string\nDesc: Everything after 'https://raw.githubusercontent.com/'")
    return
end

local fileName = args[1]
local gitLink = args[2]

local gitHttp = http.get(GUC..gitLink)
local code = ""

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
print("Complete.")


