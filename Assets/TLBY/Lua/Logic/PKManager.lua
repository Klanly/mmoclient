---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/6
-- desc： pk管理
---------------------------------------------------
require "Common/basic/LuaObject"
local constant = require "Common/constant"
local log = require "basic/log"

FriendState = {
	Normal = 1,		-- 中
	Good = 2, 		-- 善
	Bad = 4,		-- 恶　
}
PKMode = {
	Peace = 'peace', 		-- 和平
	Contry = 'country',		-- 阵营
	Party = 'faction',		-- 帮派
	Killed = 'slaughter',	-- 杀戮
	GoodEvil = 'karma',		-- 善恶
}
PKColor = {
	Green = 'green', 
	Yellow = 'yellow',
	Red = 'red',
	Darkgreen = 'darkgreen'
}

local CreatePKData = function(data)
	local self = CreateObject()

	self.uid = data.actor_id
	self.isAttackHero = false -- 是否正在攻击英雄

	self.pkNum = data.pk_value
	self.friendNum = data.karma_value
	self.pkMode = data.pk_mode
	self.forceMode = data.force_mode
	self.pkColor = data.pk_color

	self.update = function(data)
		if data.pk_value 	then self.pkNum 	= data.pk_value 	end
		if data.karma_value then self.friendNum = data.karma_value 	end
		if data.pk_mode 	then self.pkMode 	= data.pk_mode 		end
		if data.force_mode 	then self.forceMode = data.force_mode 	end
		if data.pk_color 	then self.pkColor 	= data.pk_color 	end
	end
	return self
end
-- 单个对象的pkmanager
local function CreatePKManager()
	local self = CreateObject()
	local pkInfoList = {}
	local heroPkData = nil

	local getHero = function()
		return SceneManager.GetEntityManager().hero
	end
	self.getHeroPkData = function()
		return heroPkData
	end
	self.getPkData = function(uid)
		return pkInfoList[uid]
	end
	------------------------------ 复活 ---------------------------
	-- 请求复活
	self.requestRebirth = function(rebirthType)
		-- MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_PLAYER_REBIRTH, {
		-- 	choose = rebirthType
		-- })
		local data = {}
		data.func_name = 'on_player_rebirth'
		data.choose = rebirthType
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)      --请求传送
	end

	-- 请求复活反馈
	self.onPlayerRebirth = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		local ctrl = UIManager.GetCtrl(ViewAssets.Resurrection)
		ctrl.isLock = false
		ctrl.close()
	end
	
	-- 英雄死亡了，服务器复活信息
	self.onReciveRebirthInfo = function(data)
		if SceneManager.currentFightType ~= constant.FIGHT_SERVER_TYPE.QUALIFYING_ARENA then -- 排位赛不显示复活面板
			local mainCtrl = UIManager.GetCtrl(ViewAssets.MainLandUI)
			mainCtrl.isLock = true
			UIManager.UnloadAll()
			mainCtrl.isLock = false
			UIManager.PushView(ViewAssets.Resurrection,nil,getHero(), data.rebirth_infos)
		end
	end

	-- local onRebirthAuto = function(data)
	-- 	self.requestRebirth(data.choose)
	-- end

	-------------------------- rpc pk ------------------------
	self.requestGetPKInfo = function(uid)
		log("pk", 'request rpc uid=' .. uid)
		local data = {}
		data.func_name = 'on_get_pk_info'
		data.actor_id = uid
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)      --请求传送		      
	end
	self.GetPkInfoRet = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		local pkdata = pkInfoList[data.actor_id]
		if pkdata then
			pkdata.update(data)
		else
			pkdata = CreatePKData(data)
			pkInfoList[data.actor_id] = pkdata
		end
		local hero = getHero()
		if not hero then
			return
		end

		local puppet = hero:GetEntityManager().GetPuppet(data.actor_id)
		if not puppet then
			return
		end

		puppet:UpdatePkInfo(pkdata)

		if data.actor_id == hero.uid then
			heroPkData = pkdata
		end
	end

	self.PkStateChange = function(data)
		self.GetPkInfoRet(data)
	end

	self.BeingAttacked = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		for k, v in pairs(data.evil_attacker) do
			if k and v then
				local pkdata = pkInfoList[k]
				if pkdata then
					pkdata.isAttackHero = true
					local enemy = getHero():GetEntityManager().GetPuppet(k)
					if enemy then						
						enemy:UpdatePkInfo(pkdata)
					end
				end
			end
		end
	end
	self.DarkGreenRelieve = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		local pkdata = pkInfoList[data.attacker]
		if pkdata then
			pkdata.isAttackHero = false
			local enemy = getHero():GetEntityManager().GetPuppet(data.attacker)
			if enemy then
				enemy:UpdatePkInfo(pkdata)
			end
		end
	end

	-- 请求改变hero的pk模式
	self.requestChangePKMode = function(mode)
		local data = {}
		data.func_name = 'on_change_pk_mode'
		data.pk_mode = mode
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)      --请求传送	
	end

	self.ChangePkModeRet = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		local pkdata = self.getHeroPkData()
		pkdata.pkMode = data.pk_mode
		-- getHero():UpdatePkInfo(pkdata)
	end

	local init = function()
		-- MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PLAYER_REBIRTH, onPlayerRebirth)
		-- MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PLAYER_REBIRTH_INFO, onReciveRebirthInfo)
		-- MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PLAYER_REBIRTH_AUTO, onRebirthAuto)

		MessageRPCManager.AddUser(self, 'onPlayerRebirth') 
		MessageRPCManager.AddUser(self, 'onReciveRebirthInfo') 

		MessageRPCManager.AddUser(self, 'BeingAttacked') 
		MessageRPCManager.AddUser(self, 'DarkGreenRelieve') 
		MessageRPCManager.AddUser(self, 'ChangePkModeRet')
		MessageRPCManager.AddUser(self, 'GetPkInfoRet') 
		MessageRPCManager.AddUser(self, 'PkStateChange')
	end
	self.clear = function()
		-- MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_PLAYER_REBIRTH, onPlayerRebirth)
		-- MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_PLAYER_REBIRTH_INFO, onReciveRebirthInfo)
		-- MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PLAYER_REBIRTH_AUTO, onRebirthAuto)
		-- MessageRPCManager.RemoveUser(self, 'BeingAttacked') 
		-- MessageRPCManager.RemoveUser(self, 'DarkGreenRelieve') 
		-- MessageRPCManager.RemoveUser(self, 'ChangePkModeRet') 
		-- MessageRPCManager.RemoveUser(self, 'GetPkInfoRet') 
		-- MessageRPCManager.RemoveUser(self, 'PkStateChange')
	end

	self.Clear = function()
		pkInfoList = {}
	end
	init()

	return self
end

PKManager = PKManager or CreatePKManager()