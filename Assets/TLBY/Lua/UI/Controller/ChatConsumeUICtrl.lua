---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

function CreateChatConsumeUICtrl()
    local self = CreateCtrlBase()
    local chatTable = require'Logic/Scheme/system_friends_chat'
    local channelContent = chatTable.ChannelContent
    local channel = 0
	self.onLoad = function(channelIndex)
        channel = channelIndex
        self.AddClick(self.view.btnClose,self.close)
        self.AddClick(self.view.btnCancel,self.close)
        self.AddClick(self.view.btnConfirm,self.SendMsg)
        self.view.toggle:GetComponent('Toggle').isOn = false
        local itemName = LuaUIUtil.GetItemName(channelContent[channel].Consumption[1])
        local itemCost = channelContent[channel].Consumption[2] or 0
        self.view.consumeText:GetComponent('TextMeshProUGUI').text = string.format("%s发送消息需要消耗%s*%d，确定使用吗？",channelContent[channel].ChannelName,itemName,itemCost)
	end
	
	self.onUnload = function()
        if self.view.toggle:GetComponent('Toggle').isOn then
            ChatManager.SaveChannelCost(channel)     
        end
	end
    
    self.SendMsg = function()
        UIManager.GetCtrl(ViewAssets.ChatUI).SendMsg()
        self.close()
    end
	
	return self
end

return CreateChatConsumeUICtrl()