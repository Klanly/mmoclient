require "UI/Controller/LuaCtrlBase"



local function CreateTipsUICtrl()
    local self = CreateCtrlBase()
    self.layer = LayerGroup.popCanvas
    local systemList = GetConfig('common_system_list')
    local uiText = GetConfig('common_char_chinese').UIText
    
    self.onLoad = function(id)
        self.AddClick(self.view.btnClose, self.close)
    
        if systemList.system[id] and systemList.system[id].Description ~=0 then
            self.view.des:GetComponent('TextMeshProUGUI').text = uiText[systemList.system[id].Description].NR
            
        elseif uiText[id] then
            self.view.des:GetComponent('TextMeshProUGUI').text = uiText[id].NR
        else
            self.view.des:GetComponent('TextMeshProUGUI').text = id
        end
    end

    return self
end

return CreateTipsUICtrl()


