LogConfig = {}
logConfig = LogConfig

LogConfig.unityAPI = true
local flags = { -- 日志标签
	"Game",
	"msg",
	-- "rpcmsg",
	-- "syncmsg", -- 战斗同步消息
	-- "aoi",
	-- 'scene',
	-- "aoimove",
	-- 'pk',
	-- 'task',
	-- 'maindungeon', -- 主线副本日志
	-- 'poserr',
	--'command',
};
logConfig.GetLogFlags = function()
	return flags
end

LogConfig.hasFlag = function(flag)
    for k, v in ipairs(flags) do
        if v == flag then
            return true
        end
    end
    return false
end
LogConfig.addFlag = function(flag)
	if LogConfig.hasFlag(flag) then
		return
	end
	table.insert(flags, flag)
	Util.RefreshLogFlag()
end
LogConfig.removeFlag = function(flag)
	for i = #flags, 1, -1 do
        if flags[i] == flag then
        	table.remove(flags, i)
        end
    end
    Util.RefreshLogFlag()
end


-- private --
local unityLog = function(flag, str)
	Util.Log(flag, str)
end
local luaLog = function(flag, str)
	print(str)
end
-- --错误日志--
-- local unityError = function(flag, str)
-- 	Util.LogError(flag, str)
-- end
-- local luaError = function(flag, str)
-- 	if logConfig.hasFlag(flag) then
-- 		error(str)
-- 	end
-- end


-- print message to file
local messagestr = ''
local file = nil
local rowindex = 0
function startWriteMsg()
	file = io.open("./messages.txt", "w")
	if not file then
		print('not found file')
		return
	end
	file:write('--- start ---')
end
function writeMsg(str)
	if not file then
		return
	end
	rowindex = rowindex + 1
	messagestr = messagestr .. (os.date("%c", os.time()) .. ' ' .. rowindex .. " " .. str .. '\r\n')
end
function endWriteMsg()
	file:write(messagestr)
	file:write('--- end ---')
	file:close()
	messagestr = ''
	file = nil
end

-- public below ---
local function log(flag, str, ...)
	if not LogConfig.hasFlag(flag) then
		return
	end
	local otherStr = {...}
	for i = 1, #otherStr do
		str = str .. " " .. otherStr[i]
	end
    if logConfig.unityAPI then
    	unityLog(flag, str)
    else
    	luaLog(flag, str)
    end
end

-- local function logError(flag, str, ...) 
-- 	local otherStr = {...}
-- 	for i = 1, #otherStr do
-- 		str = str .. " " .. otherStr[i]
-- 	end

--     if logConfig.unityAPI then
--     	unityError(flag, str)
--     else
--     	luaError(flag, str)
--     end
-- end

-- --警告日志--
-- local function LogWarning(flag, str, ...) 
-- 	local otherStr = {...}
-- 	for i = 1, #otherStr do
-- 		str = str .. " " .. otherStr[i]
-- 	end
-- 	Util.LogWarning(flag, str);
-- end

return log