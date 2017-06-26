--huasong--
require "Common/basic/LuaObject"

local function CreateChatBar( )
    local self = CreateObject()
    
    self.Awake = function()
        self.chatText = self.transform:Find("Bg/ChatText").gameObject:GetComponent("TextMeshProUGUI")
        self.bgRect = self.transform:Find("Bg").gameObject:GetComponent("RectTransform")
        self.recTransform = self.gameObject:GetComponent("RectTransform")    
    end

    function self.UpdateBar(followPuppet, x , y , chat)
        if chat then self.chatText.text = chat end
        local height = self.chatText.preferredHeight + 35
        local width = self.chatText.preferredWidth + 55
        if width > 600 then
            width = 600
        end
        if height < 75 then
            height = 75
        end
        self.bgRect.sizeDelta = Vector2.New(width, height)
        local followingScript = self.gameObject:GetComponent('UIFollowingTarget')
        followingScript.xOffset = x
        followingScript.yOffset = y
        followingScript.target = followPuppet.transform:Find('Body/head') or followPuppet.transform
    end
      
    return self
end

return CreateChatBar()