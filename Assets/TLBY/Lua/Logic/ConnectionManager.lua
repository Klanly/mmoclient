---------------------------------------------------
-- auth： panyinglong
-- date： 2017/5/16
-- desc： 服务连接管理
---------------------------------------------------

local CommonDefine = require("Common/constant")
local config = GetConfig('common_parameter_formula')
local conTimeout = 5000 --config.Parameter[56].Parameter -- 连接时间timeout
local reconTrytime = config.Parameter[57].Parameter -- 连接时间timeout

local showWaitUI = function(delay)
	local ctrl = UIManager.GetCtrl(ViewAssets.WaitServerResponseUI)
    if not ctrl.isLoaded then
        UIManager.PushView(ViewAssets.WaitServerResponseUI, function(c)
		    c.ShowWaiting(delay)
        end)
    else
	    ctrl.ShowWaiting(delay)
    end
end
local showReloginAndRetryUI = function()
	local ctrl = UIManager.GetCtrl(ViewAssets.WaitServerResponseUI)
    if not ctrl.isLoaded then
        UIManager.PushView(ViewAssets.WaitServerResponseUI, function(c)
		    c.ShowLogin(reconTrytime)
        end)
    else
	    ctrl.ShowLogin(reconTrytime)
    end
end
local showClosedUI = function()
	local ctrl = UIManager.GetCtrl(ViewAssets.WaitServerResponseUI)
    if not ctrl.isLoaded then
        UIManager.PushView(ViewAssets.WaitServerResponseUI, function(c)
		    c.ShowClosed()
        end)
    else
	    ctrl.ShowClosed()
    end
end
local hideWaitUI = function()
	local ctrl = UIManager.GetCtrl(ViewAssets.WaitServerResponseUI)
	if not ctrl.isClosed then
        ctrl.close()
    end
end

-- 连接基类
local function CreateConnection(connection)
	local self = CreateObject()
	self.isConnecting = false
	self.connection = connection

	self.onConSucceedCallback = nil

	-- 连接成功
	self.OnConSucceed = function()
		self.isConnecting = false
		hideWaitUI()
		if self.onConSucceedCallback then
			self.onConSucceedCallback()
		end
		self.onConSucceedCallback = nil
	end

	-- 连接
	self.Connect = function(ip, port, onSucceed)
		if self.isConnecting then
			print('重复请求, 已拒绝该重复连接')
			return
		end
		self.isConnecting = true
		showWaitUI(0.2)
		self.onConSucceedCallback = onSucceed
		self.connection:Connect(ip, port, conTimeout)
	end
	self.Close = function()
		self.connection:Close()
	end

	self.SyncTime = function()
		if self.connection.state == ConnectState.Success then
			self.connection:SyncTime()
		else
			print('连接状态错误, 无法对时')
		end
	end

	self.SetNeedSyncTime = function(b)
		self.connection.NeedSyncTime = b
	end

	-- 连接失败
	self.OnConFailed = function(msg)
		self.isConnecting = false
	end

	-- 连接成功后, 出现收发消息异常
	self.OnSocketError = function(msg)
	end

	-- 连接关闭
	self.OnConClose = function()
		self.isConnecting = false
	end

	-- 心跳停止超过time秒
	self.OnHeartDeath = function(time)
	end

	-- 断线重连
	self.Reconnect = function()
	end

	-- 直接消息
	self.messageDic = {} -- 只能是一一映射
	self.SendMessage = function(action, data, onRecive)
		print('SendMsg msg=' .. action .. ' data=' .. tostring(data))
		if onRecive then
			self.messageDic[action] = onRecive
		end
		self.connection:Send(action, data, 0)
	end
	self.OnMessage = function(action, data)
		print('OnMessage action=' .. action .. ' data=' .. tostring(data))
		if self.messageDic[action] then
			self.messageDic[action](data)
		end
	end

	self.connection.OnDefaultMessage = self.OnMessage
	return self
end

local function CreateMainConnection(connection)
	local self = CreateConnection(connection)

	local isFirstConnect = function()
		if not MyHeroManager or not MyHeroManager.heroData then
			return true
		end
		return false
	end
	-- 连接失败
	self.OnConFailed = function(msg)
		self.isConnecting = false
		if isFirstConnect() then
			hideWaitUI()
			UIManager.ShowNotice('连接失败, 请重试')
		else
			local ctrl = UIManager.GetCtrl(ViewAssets.LoginPanelUI)
			if ctrl.isLoaded then
				UIManager.ShowNotice('连接失败, 请重试')
			else
				showReloginAndRetryUI()
			end
		end
	end

	-- 连接成功后, 出现收发消息异常
	self.OnSocketError = function(msg)
		self.isConnecting = false
		if msg == 'SERVER_CLOSE' then -- 服务器关闭了连接
			showClosedUI()
		else
			self.Reconnect()
		end
	end
	-- 断线重连
	self.Reconnect = function()
		print('main connection start Reconnect')
		if isFirstConnect() then
			print('first connect')
			self.Connect(self.connection.IP, self.connection.PORT, self.onConSucceedCallback)
			return
		end
		if self.connection.state == ConnectState.Success then
			self.connection:Close()
		end
		local onRecconSucceed = function() -- 重连服务器成功,但还没有恢复数据
			local data = {}
			data.actor_id = MyHeroManager.heroData.actor_id
        	data.device_id = Game.deviceId
			print('CS_MESSAGE_LOGIN_CLIENT_RECONNECT actor_id:' .. data.actor_id .. " devid:" .. data.device_id)
        	MessageManager.RequestLua(CommonDefine.CS_MESSAGE_LOGIN_CLIENT_RECONNECT, data)
		end
	    self.Connect(self.connection.IP, self.connection.PORT, onRecconSucceed)
	end

	local OnReconnectAndRecover = function(data)
		print('OnReconnectAndRecover result=' .. data.result)
		if data.result ~= 0 then
			self.OnConFailed('重连失败')
			return
		end
	end

	local init = function()
		MessageManager.RegisterMessage(CommonDefine.SC_MESSAGE_LOGIN_CLIENT_RECONNECT, OnReconnectAndRecover)
	end
	init()
	return self
end
local function CreateFightConnection(connection)
	local self = CreateConnection(connection)
	self.ip = ""
	self.port = 0
	self.token = ""
	self.fight_id = ""

	self.failedCount = 0
	self.conData = nil

	-- 连接失败
	self.OnConFailed = function(msg)
		hideWaitUI()
		self.isConnecting = false
		self.failedCount = self.failedCount + 1
		if self.failedCount < 3 then
			Timer.Delay(0.2, function()
				self.ConnetFightServer(self.conData)
			end)			
		else
			self.failedCount = 0
			local fdata = {
				func_name = 'on_failed_connet_fight_server',
			}
			MessageManager.RequestLua(CommonDefine.CS_MESSAGE_LUA_GAME_RPC, fdata) 
			UIManager.ShowNotice('连接失败!')
		end
	end

	-- 断线重连
	self.Reconnect = function()
		showWaitUI(0.1)
		if not MyHeroManager or not MyHeroManager.heroData then
			print('未登录成功过, 无法重连')
			return
		end
		local data = {}
		data.func_name = 'on_reconnet_fight_server'
		data.actor_id = MyHeroManager.heroData.actor_id
		data.fight_id = self.fight_id
		data.token = self.token
		print('on_reconnet_fight_server actor_id:' .. data.actor_id)
		MessageManager.RequestLua(MSG.CD_MESSAGE_LUA_GAME_RPC, data)
	end
	self.ConnetFightServer = function(data)
		if self.isConnecting then
			print('正在连接战斗服, 已拒绝该重复连接')
			return
		end
		self.conData = data
		self.ip = data.ip
		self.port = data.port
		self.token = data.token
		self.fight_id = data.fight_id
		showWaitUI(0.01)
		self.Connect(self.ip, self.port, function()
			local sdata = {
				func_name = 'on_connet_fight_server',
				token = self.token,
				fight_id = self.fight_id,
				actor_id = MyHeroManager.heroData.actor_id,
			}
			MessageManager.RequestLua(CommonDefine.CD_MESSAGE_LUA_GAME_RPC, sdata) 
			self.failedCount = 0
		end)
	end
	self.ConnetFightServerRet = function(data)
		print('ConnetFightServerRet')
	end
	self.FailedConnectFightServerRet = function(data)
		print('FailedConnectFightServerRet')
	end
	self.DisconnetFightServer = function(data)
		Game.SetCanSyncMsg(false)
		local data = {}
		data.func_name = 'on_client_disconnet_fight_server'
		MessageManager.RequestLua(MSG.CD_MESSAGE_LUA_GAME_RPC, data)
	end
	self.ReconnetFightServerRet = function(data) -- 重新连接战斗服务器反馈
		hideWaitUI()
		print('ReconnetFightServerRet result=' .. data.result)
		if data.result ~= 0 then
			showReloginAndRetryUI()
			return
		end
		self.SyncTime()
	end
	self.ClientDisconnetFightServerRet = function()
		self.Close()
	end
	self.OnSocketError = function(msg)
		self.isConnecting = false
		if msg == 'SERVER_CLOSE' then -- 服务器关闭了连接
			showClosedUI()
		else
			self.Reconnect()
		end
	end

	local init = function()
		MessageRPCManager.AddUser(self, 'ConnetFightServer') 
		MessageRPCManager.AddUser(self, 'ConnetFightServerRet') 
		MessageRPCManager.AddUser(self, 'DisconnetFightServer') 
		MessageRPCManager.AddUser(self, 'ClientDisconnetFightServerRet') 
		MessageRPCManager.AddUser(self, 'FailedConnectFightServerRet')
	end
	init()
	return self
end

local function CreateConnectionManager()
	local self = CreateObject()

	local mainCon = CreateMainConnection(AppFacade.Instance.networkManager.MainConnection)
	local fightCon = CreateFightConnection(AppFacade.Instance.networkManager.FightConnection)

	self.OnStateChanged = function(con, state, msg)
		print('OnStateChanged: connection:' .. con.name .. ' state:' .. tostring(state))
		local connection = nil
		if con.name == 'Main' then
			connection = mainCon
		elseif con.name == 'Fight' then
			connection = fightCon
		else
			error('invalidate connection name')
		end

		if state == ConnectState.Unknown then
		elseif state == ConnectState.Success then
			connection.OnConSucceed()
		elseif state == ConnectState.Failed then
			connection.OnConFailed(msg)
		elseif state == ConnectState.Error then
			connection.OnSocketError(msg)
		elseif state == ConnectState.Close then
			connection.OnConClose()
		end
	end

	self.OnHeartDeath = function(con, time)
		print('OnHeartDeath name:' .. con.name)
		if con.name == 'Main' then
			mainCon.OnHeartDeath(time)
		elseif con.name == 'Fight' then
			fightCon.OnHeartDeath(time)
		end
	end

	self.ConnectLoginServer = function(ip, port, onSucceed)
		mainCon.SetNeedSyncTime(false)
		mainCon.Connect(ip, port, onSucceed)
	end
	-- main connection 
	self.ConnectMainServer = function(ip, port, onSucceed)
		mainCon.SetNeedSyncTime(true)
        mainCon.Connect(ip, port, onSucceed)
	end
	self.RequestMainServer = function(action, data, onRecive)
        mainCon.SendMessage(action, data, onRecive)
	end
	self.ReconnectMainServer = function()
		mainCon.Reconnect()
	end
	self.SyncMainTime = function()
		mainCon.SyncTime()
	end
	
	-- fight connection
	self.ConnetFightServer = function(data) -- 通常由服务端通知, 但如果在战斗服直接下线, 再上线的话, 则需要客户端调用
		fightCon.ConnetFightServer(data)
	end
	self.ReconnectFightServer = function() -- 重新连接战斗服务器
		fightCon.Reconnect()
	end
	return self
end

ConnectionManager = ConnectionManager or CreateConnectionManager()