---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/24
-- desc： 消息管理
---------------------------------------------------
require "Common/basic/Event"
require "Common/basic/LuaObject"
require "Network/MessageID"
require "Network/MessageRPCManager"
require "Logic/AOIManager"
local mp = require '3rd/messagepack/MessagePack'
local Const = require "Common/constant"
local log = require "basic/log"

local function CreateMessageManager()
	local self = CreateObject()
	local Event = CreateEvent()
	local cacheMsg = {}

	local logMsg = function(msg, unpackData)
		if msg == Const.SC_MESSAGE_LUA_GAME_RPC or msg == Const.DC_MESSAGE_LUA_GAME_RPC then 				--协议号为243，服务端发回的RPC协议
			if string.find(unpackData.func_name, 'OnSync') == 1 then
				-- log('syncmsg', table.toString(unpackData, "-- recv sync rpcmsg -- func_name=" .. unpackData.func_name .. ' --'))
				log('syncmsg', ("-- recv sync rpcmsg -- func_name=" .. unpackData.func_name .. ' --'))
			else
				-- log('rpcmsg', table.toString(unpackData, "-- recv rpcmsg -- func_name=" .. unpackData.func_name .. ' --'))	
				log('rpcmsg', ("-- recv rpcmsg -- func_name=" .. unpackData.func_name .. ' --'))	
			end
		else
			-- log('msg', table.toString(unpackData, '-- recv msg id= ' .. msg .. ' ' .. (MSG_DESC[msg] or "") .. ' --'))
			log('msg', ('-- recv msg id= ' .. msg .. ' ' .. (MSG_DESC[msg] or "") .. ' --'))
		end
	end
	
	self.RegisterMessage = function(messageID, messageHandle, owner)
		Event.AddListener(messageID, messageHandle, owner)
	end

	self.UnregisterMessage = function(messageID, messageHandle, owner)
		Event.RemoveListener(messageID, messageHandle, owner)
	end

	self.Fire = function(messageID, data)
		Event.Brocast(messageID, data)
	end

	self.FireCacheMsg = function()	
		for i = #cacheMsg, 1, -1 do
			local md = cacheMsg[i]
			self.OnLuaMessage(md.m, md.d)
	 		table.remove(cacheMsg, i)
		end
	end
	-- lua 消息
	self.OnLuaMessage = function(msg, data)
        
		if SceneManager.isSceneLoading then
			print('OnLuaMessage when SceneManager.isSceneLoading msg=' .. msg)
			table.insert(cacheMsg, {
				m = msg,
				d = data
			})
			return
		end
		local unpackData = mp.unpack(data)
        -- table.print(unpackData)
		logMsg(msg, unpackData)
        
		if unpackData.result and unpackData.result ~= 0 then
			print('msg error id=' .. msg .. ' result=' .. unpackData.result .. ' desc=' .. (MSG_ERROR[unpackData.result] or 'no desc'))
            UIManager.ShowErrorMessage(unpackData.result)
        end
		
		if msg == MSG.SC_MESSAGE_LUA_GAME_RPC or msg == MSG.DC_MESSAGE_LUA_GAME_RPC then 				--协议号为243，服务端发回的RPC协议
			MessageRPCManager.OnRPCRet(unpackData)
		end          
        self.Fire(msg, unpackData)
	end

	local getConnection = function(msg)
		if msg == Const.CD_MESSAGE_LUA_GAME_RPC then
			return AppFacade.Instance.networkManager.FightConnection
		else
			return AppFacade.Instance.networkManager.MainConnection
		end
	end
	-- lua请求
	self.RequestLua = function(msg, data, async)
		local d = data or {}
        -- table.print(d)
		-- log('msg', table.toString(d, "---- request msg id=" .. msg .. " " .. (d.func_name or "") .. " " .. (MSG_DESC[msg] or "")))  
		log('msg', ("---- request msg id=" .. msg .. " " .. (d.func_name or "") .. " " .. (MSG_DESC[msg] or "")))        
		gameMgr:GetLuaModule():RunLuaRequest(msg, mp.pack(d), getConnection(msg))
	end

	
	return self
end

MessageManager = MessageManager or CreateMessageManager()