--huasong--
require "Common/basic/LuaObject"

local function CreateHpBarUI( )
    local self = CreateObject()
    local timerInfo = nil
    local followPuppet = nil
    
    self.Awake = function()
		self.damage = self.transform:Find("damage")
        self.heal = self.transform:Find("heal")
        self.state = self.transform:Find("state")
		self.blueHp = self.transform:Find("hpBg/bluehp").gameObject:GetComponent("Image")
		self.redHp = self.transform:Find("hpBg/redhp").gameObject:GetComponent("Image")
        self.redHpBg = self.transform:Find("hpBg/redhp2").gameObject:GetComponent("Image")
        self.blueHpBg = self.transform:Find("hpBg/bluehp2").gameObject:GetComponent("Image")
        self.recTransform = self.gameObject:GetComponent("RectTransform")
        
        local vocation = self.transform:Find("hpBg/vocation")
        if vocation then
            self.vocation = vocation:GetComponent('Image')
            self.vocBg = self.transform:Find("hpBg/vocBg").gameObject
        end
        
        local greenHp = self.transform:Find('hpBg/greenhp')
        if greenHp then
            self.greenHp = greenHp:GetComponent('Image')
            self.greenHpBg = self.transform:Find("hpBg/greenhp2"):GetComponent('Image')
        end
    end
    
    self.OnDisable = function()
        UpdateBeat:Remove(self.Update, self)
        followPuppet = nil
    end
    
    self.OnEnable = function()
        UpdateBeat:Add(self.Update, self)
    end
    
    local showValue = 1
    local trueValue = 1
    self.Update = function()
        if followPuppet then
            if showValue ~= trueValue then
                if(showValue - trueValue > 0.01) then
                    showValue = showValue - 0.01
                else
                    showValue = trueValue
                end
                self.redHpBg.fillAmount = showValue
                self.blueHpBg.fillAmount = showValue
                if self.greenHpBg then self.greenHpBg.fillAmount = showValue end
            end
        end
    end
    
    function self.UpdateBar(puppetBehavior, x , y , type, hpValue,vocation)
        if followPuppet ~= puppetBehavior then
            followPuppet = puppetBehavior
            self.redHp.gameObject:SetActive(type == 1 or type == 3 or type == 5)
            self.redHpBg.gameObject:SetActive(type == 1 or type == 3 or type == 5)
            self.blueHp.gameObject:SetActive(type == 2 or type == 4)
            self.blueHpBg.gameObject:SetActive(type == 2 or type == 4)
            showValue = hpValue
            self.redHpBg.fillAmount = showValue
            self.blueHpBg.fillAmount = showValue
            if self.greenHpBg then self.greenHpBg.fillAmount = showValue end
            if type == 3 or type == 4 or type ==6 then
                self.vocation.gameObject:SetActive(true)
                self.vocBg:SetActive(true)
                if vocation then
                    self.vocation.overrideSprite = ResourceManager.LoadSprite('MainUI/voc'..vocation)
                end
            end
            if type == 5 then
                self.vocation.gameObject:SetActive(false)
                self.vocBg:SetActive(false)
            end
            if self.greenHp then
                self.greenHp.gameObject:SetActive(type == 6)
                self.greenHpBg.gameObject:SetActive(type == 6)
            end
        end
        local followingScript = self.gameObject:GetComponent('UIFollowingTarget')
        followingScript.xOffset = x
        followingScript.yOffset = y
        followingScript.target = followPuppet.transform:Find('Body/head') or followPuppet.transform
        trueValue = hpValue
        self.redHp.fillAmount = trueValue
        self.blueHp.fillAmount = trueValue
        if self.greenHp then self.greenHp.fillAmount = trueValue end
    end

    return self
end

return CreateHpBarUI()