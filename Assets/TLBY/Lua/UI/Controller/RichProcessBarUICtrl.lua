---------------------------------------------------
-- auth： panyinglong
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
local red = 'Common/progressbar/redbar'
local redPoint = 'Common/progressbar/redlight'
local blue = 'Common/progressbar/bluebar'
local bluePoint = 'Common/progressbar/bluelight'

local redPointSprite = ResourceManager.LoadSprite(redPoint)
local redSprite = ResourceManager.LoadSprite(red)
local bluePointSprite = ResourceManager.LoadSprite(bluePoint)
local blueSprite = ResourceManager.LoadSprite(blue)

local function CreateRichProcessBarUICtrl()
    local self = CreateCtrlBase()
    
    self.layer = LayerGroup.base
    self.followComp = nil
    
	self.onLoad = function()
        self.slider = self.view.slider:GetComponent('Slider')
	end
	
	self.onUnload = function()
        if self.followComp then
            GameObject.Destroy(self.followComp)
            self.followComp = nil
        end
	end
    
    self.UpdateValue = function(value)
        self.slider.value = value
    end
    
    self.UpdateText = function(text)
        self.view.des:GetComponent('TextMeshProUGUI').text = text
    end

    self.UpdateFg = function(color)
        if color == 'red' then
            self.view.point:GetComponent('Image').sprite = redPointSprite
            self.view.fg:GetComponent('Image').sprite = redSprite
        elseif color == 'blue' then
            self.view.point:GetComponent('Image').sprite = bluePointSprite
            self.view.fg:GetComponent('Image').sprite = blueSprite
        else
            error('不支持这个颜色')
        end
    end
    self.UpdateBg = function(color)
        if color == 'red' then
            self.view.bg:GetComponent('Image').sprite = redSprite
        elseif color == 'blue' then
            self.view.bg:GetComponent('Image').sprite = blueSprite
        else
            error('不支持这个颜色')
        end
    end

    self.SetFollowTarget = function(transform, offsetx, offsety)
        self.followComp = self.view.gameObject:GetComponent('UIFollowingTarget')
        if not self.followComp then 
            self.followComp = self.view.gameObject:AddComponent(typeof(UIFollowingTarget))
        end
        self.followComp.xOffset = offsetx or 0
        self.followComp.yOffset = offsety or 0
        self.followComp.worldOffset = Vector3.New(0, 6, 0)
        self.followComp.target = transform
    end
	
	return self
end

return CreateRichProcessBarUICtrl()