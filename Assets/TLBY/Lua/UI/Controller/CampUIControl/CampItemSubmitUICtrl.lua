
local function CreateCampItemSubmitUICtrl()
	local self = CreateCtrlBase()
    local taskTable = GetConfig('pvp_country_war').CampNpcTask
    local campTaskId = nil
    local npcUID = nil
    local itemUpdate = function(item,index)
        local itemId = taskTable[campTaskId].Item[index*2+1]
        local itemCount = taskTable[campTaskId].Item[index*2+2]
        item.transform:Find('name'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetItemName(itemId)
        item.transform:Find('count'):GetComponent('TextMeshProUGUI').text = BagManager.GetItemNumberById(itemId)
        item.transform:Find('des'):GetComponent('TextMeshProUGUI').text = '需求数量：'..itemCount
        item.transform:Find('icon'):GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(itemId)
        item.transform:Find('iconBg'):GetComponent('Image').overrideSprite = LuaUIUtil.GetItemQuality(itemId)
        self.AddClick(item.transform:Find('sendBtn').gameObject,function() 
            local data = {}
            data.func_name = 'submit_country_war_materials'
            data.id = campTaskId
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        end)
    end

	self.onLoad = function(id,name,uid)
        ClickEventListener.Get(self.view.btnClose).onClick = self.close
        
        campTaskId = id
        npcUID = uid
		self.view.title:GetComponent("TextMeshProUGUI").text = '提交道具'
        self.view.des:GetComponent("TextMeshProUGUI").text = string.format('向%s提交道具，长按连续提交',name)
    
        self.view.submitItem:SetActive(false)
        
        local scv = self.view.ScrollView:GetComponent(typeof(UIMultiScroller))
        scv:Init(self.view.submitItem,835,120,10,5,1)
        
        self.UpdateData()
	end

	self.UpdateData = function()
        if not self.isLoaded then return end
        
		local scv = self.view.ScrollView:GetComponent(typeof(UIMultiScroller))
        local count = math.floor((#taskTable[campTaskId].Item)/2)
        scv:UpdateData(count,itemUpdate)
	end
	
	self.onUnload = function()
        local data = {}
        data.npcuid = npcUID
        data.taskDatas = {}
        data.btns = {}
        data.dialogue = taskTable[campTaskId].CompleteDialogue
        UIManager.PushView(ViewAssets.NPCTalkUI,nil, data)
	end
	
	return self
end

return CreateCampItemSubmitUICtrl()