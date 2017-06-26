-----------------------------------------------------
-- auth： zhangzeng
-- date： 2016/11/8
-- desc： 登录UI
-----------------------------------------------------
require "UI/Controller/LuaCtrlBase"

function CreateSelectServerUICtrl()

    local self = CreateCtrlBase()
    local serverList = nil
    local UpdateServerItem = function(item,index)
        local data = serverList[index + 1]
        if data == nil then return end
        local gray = false
        local bg = item.transform:FindChild('bg'):GetComponent('Image')
        local img1 = item.transform:FindChild('img1'):GetComponent('Image')
        local img2 = item.transform:FindChild('img2'):GetComponent('Image')
        item.transform:FindChild('serverName'):GetComponent('TextMeshProUGUI').text = data.name
        item.transform:FindChild('number'):GetComponent('TextMeshProUGUI').text = (index + 1)..'区'
        item.transform:FindChild('new').gameObject:SetActive(data.new)
        bg.raycastTarget = not gray
        item.transform:FindChild('recommended').gameObject:SetActive(not gray)
        item.transform:FindChild('open').gameObject:SetActive(gray)
        if gray then
            bg.material = UIGrayMaterial.GetUIGrayMaterial()
            img1.material = UIGrayMaterial.GetUIGrayMaterial()
            img2.material = UIGrayMaterial.GetUIGrayMaterial()
        else
            bg.material = nil
            img1.material = nil
            img2.material = nil
            self.AddClick(bg.gameObject,function() self.SetServer(data) end)
        end
    end
    
	function self.onLoad()
        serverList = Game.GetServerList()
        
        self.view.pageServer:SetActive(true) 
        self.view.pageAccount:SetActive(false)
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.serverItem,640,110,0,14,2)
        local serverList = Game.GetServerList()
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#serverList,UpdateServerItem)
        
		self.AddClick(self.view.btnClose,self.close) 
        --ClickEventListener.Get(self.view.btnMyServer).onClick = function() self.view.pageServer:SetActive(false) self.view.pageAccount:SetActive(true) end
        ClickEventListener.Get(self.view.tab).onClick = function() self.view.pageServer:SetActive(true) self.view.pageAccount:SetActive(false) end
	end
	
	-- 当view被卸载时事件
	function self.onUnload()
		MessageManager.UnregisterMessage(constant.SC_MESSAGE_LOGIN_LOGIN, OnLoginReceive)
	end
	
    self.SetServer = function(info)
        local ctrl = UIManager.GetCtrl(ViewAssets.LoginPanelUI)
        if ctrl then
            ctrl.SetServer(info)
        end
    end
    
    return self
end

return CreateSelectServerUICtrl()