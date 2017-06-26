local function CreatePlayerResourceUICtrl()
	local self = CreateCtrlBase()
    
    local resource_name_to_id = (require "Common/constant").RESOURCE_NAME_TO_ID
    
    local fixedResource = {
        resource_name_to_id.ingot,
        resource_name_to_id.silver,
        resource_name_to_id.coin,
        resource_name_to_id.bind_coin,
    }
    
    local allResource = {}
    local resourceItems = {}
    
	self.onLoad = function()
        self.view.item:SetActive(false)
	end
	
	self.onUnload = function()
        for i=1,#resourceItems do
            GameObject.Destroy(resourceItems[i])
        end
        resourceItems = {}
	end
	
    self.UpdateDynamicData = function(data)
        allResource = {}
        for i=1,#fixedResource do
            table.insert(allResource,fixedResource[i])
        end
        if data then
            for i=1,#data do
                if data[i]~=fixedResource[1] and data[i]~=fixedResource[2] and data[i]~=fixedResource[3] and data[i]~=fixedResource[4] then
                    table.insert(allResource,data[i])
                end
            end
        end
        self.UpdateData()
    end
    
	self.onActive = function()
	end

	self.onDeactive = function()
	end
    
    self.UpdateData = function()
        if not self.isLoaded then return end
        
        for i=1,#allResource do
            if i > #resourceItems then
                local item = GameObject.Instantiate(self.view.item)
                item:SetActive(true)
                item.transform:SetParent(self.view.layoutGroup.transform,false)
                table.insert(resourceItems,item)
            end
            
            local icon = resourceItems[i].transform:Find('icon'):GetComponent('Image')
            icon.overrideSprite = LuaUIUtil.GetItemIcon(allResource[i])
            local count = resourceItems[i].transform:Find('text'):GetComponent('TextMeshProUGUI')
            count.text = BagManager.GetItemNumberById(allResource[i])
            self.AddClick(resourceItems[i].transform:Find('btnAdd').gameObject,nil)
            
            resourceItems[i]:SetActive(true)
        end
        for i=#allResource+1,#resourceItems do
            resourceItems[i]:SetActive(false)
        end
    end

	return self
end

return CreatePlayerResourceUICtrl()