local module = {}

module.compile = function(...)
    local args = {...}
    local p = ""
    for i,a in pairs(args) do
        p = p..a
        if i ~= #args then p = p..","; end
    end
    return p
end

module.parse = function(packet)
    sep = sep or "%s"
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        local arg = str:match( "^%s*(.-)%s*$" )
        --print("Found arg: "..arg)
        table.insert(t,arg) -- match: clears start and end whitespace
    end
    return t
end

function split(inputstr, sep)
    sep = sep or "%s"
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        local arg = str:match( "^%s*(.-)%s*$" )
        --print("Found arg: "..arg)
        table.insert(t,arg) -- match: clears start and end whitespace
    end
    return t
end

return module