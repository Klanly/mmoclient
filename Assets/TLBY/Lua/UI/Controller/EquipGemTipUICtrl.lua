---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateEquipGemTipUICtrl()
    local self = CreateCtrlBase()
    
    local itemTable = require "Logic/Scheme/common_item"

    local Close = function()
        UIManager.UnloadView(ViewAssets.EquipGemTipUI)
    end
    
    self.onLoad = function(id,btnText1,btnFunc1,btnText2,btnFunc2,wroldPos)
        local position = Vector3.zero
        if wroldPos then
            self.uiCamera = CameraManager.uiCamera
            local ret
            local pos
            ret,pos = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.view.pos.transform.parent, 
                UnityEngine.RectTransformUtility.WorldToScreenPoint(self.uiCamera,wroldPos), self.uiCamera, 1)
            
            if pos and pos.x > 0 then
               position = Vector3.New(pos.x-320,0)
            elseif pos then
               position = Vector3.New(pos.x+320,0)
            end
        end
        self.view.pos:GetComponent('RectTransform').anchoredPosition = position
        self.view.icon:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(id)
        self.view.bgicon:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemQuality(id)
        local config = itemTable.Item[id]
        self.view.name:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetItemName(id)
        self.view.level:GetComponent('TextMeshProUGUI').text = '使用等级：'..config.LevelLimit
        self.view.des:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(config,'Description')
        self.view.btnText1:GetComponent('TextMeshProUGUI').text = btnText1
        self.AddClick(self.view.btnClose,Close)
        self.AddClick(self.view.btnImage1,btnFunc1)
        self.AddClick(self.view.mask,Close)
        
        self.view.btn2:SetActive(btnText2~=nil)
        if btnText2 then 
            self.view.btnText2:GetComponent('TextMeshProUGUI').text = btnText2
            self.AddClick(self.view.btnImage2,btnFunc2)
        end  
    end
    
    return self
end

return CreateEquipGemTipUICtrl()