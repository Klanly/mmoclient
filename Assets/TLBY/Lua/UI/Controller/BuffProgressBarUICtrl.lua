---------------------------------------------------
-- auth： songhua
---------------------------------------------------

require "UI/Controller/LuaCtrlBase"

local function CreateBuffProgressBarUICtrl()
    local self = CreateCtrlBase()
    local leftTime = 0
    local totalTime = 0
    local currentBar
    local processTimer = nil
    local countDown = nil 
    
    self.layer = LayerGroup.base
    
    local ShowBar = function(buff)
        self.view.sliderDizzy:SetActive(false)
        self.view.sliderCharm:SetActive(false)
        self.view.sliderPetrifaction:SetActive(false)
        self.view.sliderFear:SetActive(false)

        currentBar = self.view['slider'..buff]:GetComponent('Slider')
        currentBar.gameObject:SetActive(true)
    end
    
    local UpdateProcessBar = function()
        leftTime = leftTime - UnityEngine.Time.deltaTime
        countDown.text = string.format('%.1fs',leftTime)
        currentBar.value = leftTime / totalTime
        if leftTime <= 0 then
            self.close()
        end
    end
    
    self.UpdateBar = function(buff,buffTime)
        
        if self.view['slider'..buff] == nil then self.close() return end
        
        leftTime = buffTime
        totalTime = buffTime
        ShowBar(buff)
        if processTimer == nil then
            processTimer = true
            UpdateBeat:Add(UpdateProcessBar,self)
        end
    end
    
    self.onLoad = function()
        countDown = self.view.textTime:GetComponent('TextMeshProUGUI')
    end
	
	self.onUnload = function()
        if processTimer then UpdateBeat:Remove(UpdateProcessBar,self) processTimer = nil end
	end
    
	return self
end

return CreateBuffProgressBarUICtrl()