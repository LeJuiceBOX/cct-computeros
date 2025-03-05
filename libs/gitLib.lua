-- Save as 'github_files.lua'

local module = {}

module.getRepoFiles = function(owner, repo, path, recursive, max_depth, includePath)
    includePath = includePath or true
    recursive = recursive or false
    max_depth = max_depth or 3  -- Default maximum recursion depth
    
    -- Base case for recursion depth
    if max_depth < 0 then
        return {}
    end
    
    local url = string.format("https://api.github.com/repos/%s/%s/contents/%s", owner, repo, path)
    local response = http.get(url)
    
    if not response then
        return nil, "Failed to connect to GitHub"
    end
    
    local status_code = response.getResponseCode()
    if status_code ~= 200 then
        response.close()
        return nil, ("HTTP error %d: %s"):format(status_code, response.readAll() or "Unknown error")
    end
    
    local data = response.readAll()
    response.close()
    
    local success, parsed = pcall(textutils.unserialiseJSON, data)
    if not success then
        return nil, "Failed to parse JSON response"
    end
    
    if type(parsed) ~= "table" then
        return nil, "Unexpected response format"
    end
    
    local file_names = {}
    
    for _, item in ipairs(parsed) do
        if item.type == "file" then
            table.insert(file_names, {
                Name = item.name,
                Path = item.path,
                Download = item.download_url
            })
        elseif recursive and item.type == "dir" then
            -- Recursively search directory with reduced depth
            local sub_files, err = module.getRepoFiles(
                owner,
                repo,
                item.path,  -- Use full path from API response
                true,       -- Maintain recursion
                max_depth - 1
            )
            
            if not sub_files then
                return nil, err  -- Propagate errors up
            end
            
            -- Merge results from subdirectory
            for _, sub_file in ipairs(sub_files) do
                table.insert(file_names, sub_file)
            end
        end
    end
    
    return file_names
end

return module