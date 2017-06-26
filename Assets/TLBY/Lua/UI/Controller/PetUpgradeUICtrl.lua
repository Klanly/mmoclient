require "UI/Controller/LuaCtrlBase"

local function CreatePetUpgradeUICtrl()
	local self = CreateCtrlBase()
    self.layer = LayerGroup.popCanvas
    
    local itemtable = (require "Logic/Scheme/common_item").Item
    local const = require "Common/constant"
    local petUI = nil
    local GetPillData = function()
        local pills = {}
        for _,item in pairs(itemtable) do
            if item.Type == const.TYPE_EXP_PILL then
                table.insert(pills,item)
            end
        end
        table.sort(pills,function(a,b) return a.LevelLimit<b.LevelLimit end)
        return pills
    end
    
    local itemList = {}       
    local dataList = GetPillData()
    
    local Upgrade = function(id)
        local data = {}
        data.func_name = 'on_pet_use_exp_pill'
		data.pet_uid = petUI.selectPetData.entity_id
        data.item_id = id
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    local UpdateItem = function(item,data)
        local bg = item.transform:FindChild("bg").gameObject
        bg:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemQuality(data.ID)
        local icon = item.transform:FindChild("icon"):GetComponent('Image')
        icon.overrideSprite = LuaUIUtil.GetItemIcon(data.ID)
        item.transform:FindChild("des"):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetItemName(data.ID)
        local own = BagManager.GetItemNumberById(data.ID)
        item.transform:FindChild("num"):GetComponent('TextMeshProUGUI').text = own
        if own >0 then
            icon.material = nil
            ClickEventListener.Get(bg).onClick = function() Upgrade(data.ID) end
        else
            icon.material = UIGrayMaterial.GetUIGrayMaterial()
            ClickEventListener.Get(bg).onClick = nil
        end
    end
    
	self.onLoad = function()
        ClickEventListener.Get(self.view.bg).onClick = self.close
        petUI = UIManager.GetCtrl(ViewAssets.PetUI)
        self.view.item:SetActive(true)
        self.RefreshUI()
        self.view.item:SetActive(false)
	end
    
    self.RefreshUI = function()
        if not self.isLoaded then return end
        
        for i=1,#dataList do
            if itemList[i] == nil then
                local clone = GameObject.Instantiate(self.view.item)
                clone.transform:SetParent(self.view.grid.transform,false)
                table.insert(itemList,clone)
            end
            UpdateItem(itemList[i],dataList[i])
        end
        for i = #dataList+1 ,#itemList do
            GameObject.Destroy(itemList[i])
            itemList[i] = nil
        end
    end
    
    self.onUnload = function()
        for i = 1, #itemList do
            GameObject.Destroy(itemList[i])
        end
        itemList = {}
    end

	return self
end

return CreatePetUpgradeUICtrl()