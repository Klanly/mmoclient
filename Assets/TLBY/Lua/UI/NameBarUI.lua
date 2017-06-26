--huasong--
require "Common/basic/LuaObject"

local function CreateNameBarUI( )
    local self = CreateObject()
    
    self.Awake = function()
        self.nameText = self.transform.gameObject:GetComponent("TextMeshProUGUI")
        self.recTransform = self.gameObject:GetComponent("RectTransform")
        self.redFlag = self.transform:Find('flagRed').gameObject
        self.blueFlag = self.transform:Find('flagBlue').gameObject
    end

    self.OnEnable = function()
        self.HideTeamFlag()
    end

    self.UpdateBar = function(followPuppet, x , y , name)
        --self.gameObject:SetActive(true)
        local followingScript = self.gameObject:GetComponent('UIFollowingTarget')
        followingScript.xOffset = x
        followingScript.yOffset = y
        followingScript.target = followPuppet.transform:Find('Body/head') or followPuppet.transform
        self.nameText.text = name
    end
    
    self.ShowTeamFlag = function(captain)
        self.redFlag:SetActive(captain)
        self.blueFlag:SetActive(not captain)
    end
    
    self.HideTeamFlag = function()
        self.redFlag:SetActive(false)
        self.blueFlag:SetActive(false)
    end
    
    return self
end

return CreateNameBarUI()