-----------------------------------------------------
-- auth： zhangzeng
-- date： 2016/11/8
-- desc： 登录UI
-----------------------------------------------------
require "UI/Controller/LuaCtrlBase"

function CreateLoginPanelUICtrl()

    local self = CreateCtrlBase()
    local serverInfo = nil
	local actorsData = nil
    local requestTimeInfo
    local serverList = nil
    
	local function OnLoginRequest()	
		local view = self.view
		
        self.SetServer()
        self.view.waiting:SetActive(true)
        self.view.LoginBtn:SetActive(false)
        requestTimeInfo = Timer.Delay(5,self.UnlockRequest)
	end
    
    local SelectActor = function()
		CameraManager.CameraController.gameObject:SetActive(false)	
        SceneManager.EnterScene('SelectActorScence', function()
			if #actorsData.actor_list <= 0 then
				UIManager.LoadView(ViewAssets.CreateRoleUI,nil, actorsData)
			else
				UIManager.LoadView(ViewAssets.SelectRoleUI,nil, actorsData)
			end	
			
		end)
    end
    
    local OnEnterGame = function()
        local selectData = nil
        local nameLabel = self.view.textCharacter:GetComponent('TextMeshProUGUI')

        for i=1,#actorsData.actor_list do
            if nameLabel.text == actorsData.actor_list[i].actor_name then
                selectData = actorsData.actor_list[i]
            end
        end

        if selectData then
            UnityEngine.PlayerPrefs.SetString("ActorName", selectData.actor_name)
            MessageManager.RequestLua(MSG.CS_MESSAGE_LOGIN_SELECT_ACTOR, {
                actor_name = selectData.actor_name,
                actor_id = selectData.actor_id
            })
        else
            SelectActor()
        end
    end
	
	local function OnLoginReceive(data)	
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
        UIManager.UnloadView(ViewAssets.SelectServerUI)
        self.view.enter:SetActive(true)
        self.view.login:SetActive(false)
        self.view.create:SetActive(false)
        actorsData = data
        local nameLabel = self.view.textCharacter:GetComponent('TextMeshProUGUI')
        nameLabel.text = '<color=#969696FF>请创建角色'
        if #data.actor_list > 0 then
            actorName = UnityEngine.PlayerPrefs.GetString("ActorName")
            for i=1,#data.actor_list do
                if actorName == data.actor_list[i].actor_name then
                    nameLabel.text = actorName
                end
            end
            if nameLabel.text == '<color=#969696FF>请创建角色' then
                nameLabel.text = data.actor_list[1].actor_name
            end
        end
	end
        
    local OnRegist = function(data)
        if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
    end
    
    local OnLogin = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_LOGIN)
	end
    
    local ShowCreateAccount = function()
        self.view.create:SetActive(true)
        self.view.login:SetActive(false)
    end
    
    local ShowLogin = function()
        self.view.create:SetActive(false)
        self.view.login:SetActive(true)
    end
    
    local CreateAccount = function()
        local serverInfo = nil
        local servername = UnityEngine.PlayerPrefs.GetString("ServerName")
        for i=1 ,#serverList do
            if serverList[i].name == servername then
                serverInfo = serverList[i]
            end
        end
        if serverInfo == nil then
            serverInfo = serverList[1]
        end

        self.view.textServer:GetComponent('TextMeshProUGUI').text = serverInfo.name
        UnityEngine.PlayerPrefs.SetString("ServerName", serverInfo.name)

        ConnectionManager.ConnectMainServer(serverInfo.ip, serverInfo.port, function()    
            local data = {}
            data.user_name = self.view.TelInput:GetComponent('TMP_InputField').text
            data.password = self.view.SetPwdInput:GetComponent('TMP_InputField').text
            data.redist_code = self.view.ActiveCodeInput:GetComponent('TMP_InputField').text

            MessageManager.RequestLua(MSG.CS_MESSAGE_LOGIN_REGIST,data)
        end)
    end

	function self.onLoad()
        serverList = Game.GetServerList()
		local view = self.view
		view.enter:SetActive(false) 
        view.login:SetActive(true)
        view.create:SetActive(false)
        view.textVersion:GetComponent('TextMeshProUGUI').text = Util.GetLocalPatchVersion()
        view.NameInput:GetComponent("TMP_InputField").text = UnityEngine.PlayerPrefs.GetString("UserName")    
        view.PwdInput:GetComponent("TMP_InputField").text = UnityEngine.PlayerPrefs.GetString("Password")
        
		ClickEventListener.Get(view.LoginBtn).onClick = OnLoginRequest
        self.view.LoginBtn:SetActive(true)
        self.view.waiting:SetActive(false)
        ClickEventListener.Get(view.btnEnterGame).onClick = OnEnterGame
        self.AddClick(view.btnAccount, function() view.enter:SetActive(false) view.login:SetActive(true) end)
        self.AddClick(view.btnSelectServer, function() UIManager.PushView(ViewAssets.SelectServerUI) end)
        self.AddClick(view.btnAnnouncement, function() UIManager.PushView(ViewAssets.SelectServerUI) end)
        self.AddClick(view.btnSelectCharacter, SelectActor)
        self.AddClick(view.CreateAccount, ShowCreateAccount)
        self.AddClick(view.BtnCreateAccount, CreateAccount)
        self.AddClick(view.btnCloseCreate, ShowLogin)
		MessageManager.RegisterMessage(constant.SC_MESSAGE_LOGIN_LOGIN, OnLoginReceive)
        MessageManager.RegisterMessage(constant.SC_MESSAGE_LOGIN_SELECT_ACTOR, OnLogin)
        MessageManager.RegisterMessage(constant.SC_MESSAGE_LOGIN_REGIST , OnRegist)
	end
	
	-- 当view被卸载时事件
	function self.onUnload()
		MessageManager.UnregisterMessage(constant.SC_MESSAGE_LOGIN_LOGIN, OnLoginReceive)
        MessageManager.UnregisterMessage(constant.SC_MESSAGE_LOGIN_SELECT_ACTOR, OnLogin)
        MessageManager.UnregisterMessage(constant.SC_MESSAGE_LOGIN_REGIST, OnRegist)
        
        if requestTimeInfo then		
			Timer.Remove(requestTimeInfo)
			requestTimeInfo = nil
		end
	end
    
    self.UnlockRequest = function()
        --ClickEventListener.Get(self.view.LoginBtn).onClick = OnLoginRequest
        self.view.LoginBtn:SetActive(true)
        self.view.waiting:SetActive(false)
	end
	
    self.SetServer = function(info)
        local serverInfo = info
        if serverInfo == nil then
            local servername = UnityEngine.PlayerPrefs.GetString("ServerName")
            for i=1 ,#serverList do
                if serverList[i].name == servername then
                    serverInfo = serverList[i]
                end
            end
            if serverInfo == nil then
                serverInfo = serverList[1]
            end
        end

        self.view.textServer:GetComponent('TextMeshProUGUI').text = serverInfo.name
        UnityEngine.PlayerPrefs.SetString("ServerName", serverInfo.name)

		local inpuetNameValue = self.view.NameInput:GetComponent("TMP_InputField")
		local inpuetPwdValue = self.view.PwdInput:GetComponent("TMP_InputField")
        UnityEngine.PlayerPrefs.SetString("UserName", inpuetNameValue.text)
        UnityEngine.PlayerPrefs.SetString("Password", inpuetPwdValue.text)
        
        ConnectionManager.ConnectMainServer(serverInfo.ip, serverInfo.port, function()    
            local inpuetNameValue = self.view.NameInput:GetComponent("TMP_InputField")
            local inpuetPwdValue = self.view.PwdInput:GetComponent("TMP_InputField")
            local data = {}
            data.user_name = inpuetNameValue.text
            data.password = inpuetPwdValue.text
            data.device_id = Game.deviceId
            MessageManager.RequestLua(constant.CS_MESSAGE_LOGIN_LOGIN, data)
        end)
    end
    
    return self
end

return CreateLoginPanelUICtrl()