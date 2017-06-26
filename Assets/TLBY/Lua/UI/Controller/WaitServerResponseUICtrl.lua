require "UI/Controller/LuaCtrlBase"

local function CreateWaitServerResponseUICtrl()
	local self = CreateCtrlBase()
    local timer = nil
    self.layer = LayerGroup.network
    
    local BackToLogin = function()
        SceneManager.EnterScene('ReLogin', function() UIManager.PushView(ViewAssets.LoginPanelUI) end)  
    end

    local TryAgain = function()
        if SceneManager.IsOnFightServer() then
            ConnectionManager.ReconnectFightServer()
        else
            ConnectionManager.ReconnectMainServer()
        end
    end    

    local removeTimer = function()
        if timer then
            Timer.Remove(timer)
        end
        timer = nil
    end
    
    self.onLoad = function()
        self.view.waitPart:SetActive(false)
        self.view.reloginPart:SetActive(false) 
        self.view.closedPart:SetActive(false)
        self.AddClick(self.view.relogin, TryAgain)
        self.AddClick(self.view.back, BackToLogin)
        self.AddClick(self.view.btnOK, BackToLogin)
    end
	
	self.onUnload = function()
        removeTimer()
	end
    
    self.ShowWaiting = function(delay)
        self.view.closedPart:SetActive(false)
        self.view.reloginPart:SetActive(false) 
        removeTimer()
        timer = Timer.Delay(delay, function() 
            if self.isLoaded then
                self.view.waitPart:SetActive(true)
            end
        end)
    end
    self.ShowLogin = function(autoTime)
        self.view.reloginPart:SetActive(true) 
        self.view.waitPart:SetActive(false)
        self.view.closedPart:SetActive(false)
        removeTimer()
        local curtime = autoTime
        timer = Timer.Repeat(1, function() 
            curtime = curtime - 1
            if self.isLoaded then
                self.view.retryTime:GetComponent('TextMeshProUGUI').text = '重试(' .. curtime .. 'S)'
            end
            if curtime <= 0 then
                removeTimer()
                TryAgain()
                self.close()
            end
        end)
    end
    self.ShowClosed = function()
        self.view.reloginPart:SetActive(false) 
        self.view.waitPart:SetActive(false)
        self.view.closedPart:SetActive(true)
    end

	return self
end

return CreateWaitServerResponseUICtrl()
