

local module = {}

module.getFileNames = function(owner,repo,startPath)
    local url = string.format("https://api.github.com/repos/%s/%s/contents/%s", owner, repo, startPath)
    local json_response = fetch_github_folder_contents(url)
    local data = textutils.unserializeJSON(json_response)
    if not data then
        error("Failed to parse JSON response")
    end
    local files = {}
    local function _grab_files_recursive(url,webData)
        for _, item in ipairs(data) do
            if item.type == "file" then
                table.insert(files,item.path)
            elseif item.type == "dir" then
                -- Recursively fetch contents of the subdirectory
                _grab_files_recursive(item.url,webData)
            end
        end
    end
    _grab_files_recursive(url,data)
    return files
end

function fetch_github_folder_contents(url)
    local response = http.get(url)
    if not response then
        error("Failed to fetch data from GitHub API")
    end
    local data = response.readAll()
    response.close()
    return data
end


return module