require "UI/Controller/LuaCtrlBase"

local function CreateCampBattleStatusUICtrl()
    local self = CreateCtrlBase()
    
	local battleRecord = nil
    local textTable = GetConfig('common_char_chinese').UIText
    
    local BindData = function(item,index)
        local data = battleRecord[index+1]
        item.transform:Find('textLog'):GetComponent('TextMeshProUGUI').text = string.format(textTable[data.text_id].NR,unpack(data.param))
    end

    
    self.onLoad = function(data)
        self.AddClick(self.view.btnClose,self.close)
        
        battleRecord = data
        self.AddClick(self.view.btnClose,self.close)
        self.view.logItem:SetActive(false)
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.logItem,1053.51,50,0,15,1)
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#battleRecord,BindData)
    end


    return self
end

return CreateCampBattleStatusUICtrl()

