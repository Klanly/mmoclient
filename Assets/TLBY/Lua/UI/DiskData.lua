local mp = require '3rd/messagepack/MessagePack'
local path = Util.DataPath .."/%s.msdata"

WriteActorFile = function(fileName,guid,tb)
    WriteFile(guid..'_'..fileName,tb)
end

WriteFile = function(fileName,tb)
    local file = io.open(string.format(path,fileName), "wb")
    assert(file)
    local str = mp.pack(tb)
    file:write(str)
    file:close()
end

ReadActorFile = function(fileName,guid)
    return ReadFile(guid..'_'..fileName,tb)
end

ReadFile = function(fileName)
    local file = io.open(string.format(path,fileName), "rb")
    if not file then
        return nil
    end
    assert(file)
    local tb = mp.unpack(file:read("*all"))
    file:close()
    return tb
end