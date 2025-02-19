local module = {}

module.compile = function(...)
    local args = {...}
    local p = ""
    for i,a in pairs(args) do
        if a == "" or a == nil then
            a = "nil"
        end
        p = p..a
        if i ~= #args then p = p..","; end
    end
    return p
end

module.parse = function(packet)
    sep = ","
    local t = {}
    for str in string.gmatch(packet, "([^"..sep.."]+)") do
        local arg = str
        --print("Found arg: "..arg)
        if arg == "nil" then
            arg = nil
        end
        table.insert(t,arg) -- match: clears start and end whitespace
    end
    return t
end

return module