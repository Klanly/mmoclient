---------------------------------------------------
-- auth： zz
-- date： 2016/12/12
-- desc： RPC消息管理
---------------------------------------------------
local log = require "basic/log"
local function CreateMessageRPCManager()
	local self = CreateObject()
	userManage = {} 

	self.AddUser = function(user, funName)
		if not user then
			return 
		end
		if not userManage[funName] then
			userManage[funName] = {}
		end
		userManage[funName][tostring(user)] = user
	end
	
	self.RemoveUser = function(user, funName)
		if not user then
			return
		end
		if userManage[funName] then 
			for k, v in pairs(userManage[funName]) do
				if k == tostring(user) then
					userManage[funName][k] = nil
				end
			end
		end
	end
	
	--RPC
	self.OnRPCRet = function(data)
		local result = data.result
		-- if result ~= 0 and result ~= nil then	--请求失败		
		-- 	UIManager.ShowErrorMessage(result)
		-- 	return
		-- end
		
		if data.func_name == 'ServerTipsMessage' then	--服务端推送的提示文字
			 UIManager.ShowNotice(data.message)
			return
		end
		
		local users = userManage[data.func_name]
		if users then
			for k, user in pairs(users) do
				user[data.func_name](data)
			end
		end
	end


	self.SystemDirectMessage = function(data)
		table.print(data, '-- recv SystemDirectMessage --')
		UIManager.ShowNotice(data.msg)
	end

	local init = function()
		self.AddUser(self, 'SystemDirectMessage')
	end
	init()

	return self
end

MessageRPCManager = MessageRPCManager or CreateMessageRPCManager()