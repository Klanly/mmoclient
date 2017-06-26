require 'Logic/ConnectionManager'

local function CreateConnectToLogin()
    local json = require "cjson"
	local self = CreateObject()
    local cacheToken = nil
    
    local CallBack = function()
        print('connect succeed callBack')        
        local data = {}
        data.token = cacheToken
        local json = require "cjson"
        local jData = json.encode(data)
        ConnectionManager.RequestMainServer(666, jData, self.Receive)
    end

	self.ConnectToLoginServer = function(token)
        print('ConnectToLoginServer token:' .. token)
        cacheToken = token
        ConnectionManager.ConnectLoginServer("183.131.0.234",4004,CallBack)
	end
    
    self.Receive = function(j)
        print('receive jsondata:' .. j)
        local d = json.decode(j)
        
        if d.result == 1 then
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
            
            ConnectionManager.ConnectMainServer(serverInfo.ip, serverInfo.port, function()    
                local data = {}
                data.user_name = d.userid
                data.password = cacheToken
                data.device_id = Game.deviceId
                MessageManager.RequestLua(constant.CS_MESSAGE_LOGIN_LOGIN, data)
            end)
        end
        MessageManager.UnregisterMessage(666, self.Receive)
    end
  
	return self
end

ConnectToLogin = ConnectToLogin or CreateConnectToLogin()

