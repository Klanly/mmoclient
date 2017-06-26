---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/LuaUIUtil"
require "Logic/Bag/ItemType"

local CreateChatAdditionUICtrl = function()
    local self = CreateObject()
    local selectTabIndex = 1
    local ChatUICtrl = nil
    
    local UpdatePetItem = function(item,key) 
        local data = MyHeroManager.heroData.pet_list[key+1]
        item:SetActive(data ~= nil)
        if data == nil then return end
        item.transform:FindChild('name'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetPetName(data.pet_id)
        local icon = item.transform:FindChild("icon"):GetComponent("Image")
        icon.overrideSprite = LuaUIUtil.GetPetIcon(data.pet_id)
        ChatUICtrl.AddClick(item.transform:FindChild('bg').gameObject, function() self.PetClick(data) end )
    end
    
    local UpdatePropItem = function(item,key) 
        local data = BagManager.items[key+1]
        item:SetActive(data ~= nil)
        if data == nil then return end
        local icon = item.transform:FindChild("icon"):GetComponent("Image")
        icon.overrideSprite = LuaUIUtil.GetItemIcon(data.id)
        local quality = item.transform:FindChild("bg"):GetComponent("Image")
        quality.overrideSprite = LuaUIUtil.GetItemQuality(data.id)
        ChatUICtrl.AddClick(item.transform:FindChild('bg').gameObject, function() self.ItemClick(data) end )
    end
    
    self.Open = function()
        ChatUICtrl = UIManager.GetCtrl(ViewAssets.ChatUI)
        if ChatUICtrl.view == nil then return end
        
        for i=1,3 do
            local name = string.format('f%03d',i)
            ChatUICtrl.AddClick(ChatUICtrl.view[name],function() self.Expression(string.format('<sprite=%d>',i)) end)
        end
        
        for i=1,4 do
            ChatUICtrl.AddClick(ChatUICtrl.view['additionTab'..i],function() self.TabSelect(i) end)
        end
        
        for i=1,5 do
            local inputField = ChatUICtrl.view['quickMsgInput'..i]:GetComponent('TMP_InputField')
            local msgs = ChatManager.GetQuickMsg()
            if msgs[i] then
                inputField.text = msgs[i]
            end
            ChatUICtrl.AddClick(ChatUICtrl.view['quickMsg'..i],function() self.QuickMsgClick(inputField) end)
        end
        
        ChatUICtrl.view.additionPart:SetActive(true)
        ChatUICtrl.view.overlay:SetActive(true)
        ChatUICtrl.view.itemScrollView:GetComponent('UIMultiScroller'):Init(ChatUICtrl.view.propItem,112,112,0,24,6)
        ChatUICtrl.view.propItem:SetActive(false)
        ChatUICtrl.view.petScrollView:GetComponent('UIMultiScroller'):Init(ChatUICtrl.view.petItem,340,90,0,10,2)
        ChatUICtrl.view.petItem:SetActive(false)
        self.TabSelect(selectTabIndex)
    end
    
    self.Close = function()
        ChatUICtrl = UIManager.GetCtrl(ViewAssets.ChatUI)
        if not ChatUICtrl.view then return end
               
        if ChatUICtrl.view.additionPart.activeSelf then
            local msgs = {}
            for i=1,5 do
                local inputField = ChatUICtrl.view['quickMsgInput'..i]:GetComponent('TMP_InputField')
                msgs[i] = inputField.text
            end
            ChatManager.SaveQuickMsg(msgs)
        end
        ChatUICtrl.view.additionPart:SetActive(false)
        ChatUICtrl.view.overlay:SetActive(false)
    end
    
    self.TabSelect = function(index)
        selectTabIndex = index
        ChatUICtrl.view.additionLightTab.transform.position = ChatUICtrl.view['additionTab'..index].transform.position
        ChatUICtrl.view.additionLightText:GetComponent('TextMeshProUGUI').text = ChatUICtrl.view['additionTabText'..index]:GetComponent('TextMeshProUGUI').text
        ChatUICtrl.view.itemScrollView:SetActive(false)
        ChatUICtrl.view.petScrollView:SetActive(false)
        
        if selectTabIndex == 2 then
            ChatUICtrl.view.itemScrollView:SetActive(true)
            ChatUICtrl.view.itemScrollView:GetComponent('UIMultiScroller'):UpdateData(#BagManager.items,UpdatePropItem)
        elseif selectTabIndex == 3 then
            local ShowPetList = function()
                ChatUICtrl.view.petScrollView:SetActive(true)
                ChatUICtrl.view.petScrollView:GetComponent('UIMultiScroller'):UpdateData(#MyHeroManager.heroData.pet_list,UpdatePetItem) 
            end
            UIManager.GetCtrl(ViewAssets.PetUI).GetPetList(ShowPetList)
        end
        
        ChatUICtrl.view.face:SetActive(selectTabIndex == 1)
        ChatUICtrl.view.quickMsg:SetActive(selectTabIndex == 4)
    end
    
    self.QuickMsgClick = function(iF)
        if iF.text ~= '' then
            ChatUICtrl.inputField.text = iF.text
            ChatUICtrl.CloseSubPage()
        end
    end
    
    self.Expression = function(name)
        ChatUICtrl.inputField.text = ChatUICtrl.inputField.text..name
    end
    
    self.PetClick = function(petData)
        local attachInfo = {}
        attachInfo.str = LuaUIUtil.GetPetName(petData.pet_id)
        attachInfo.type = 'pet'
        attachInfo.data = petData
        ChatUICtrl.UpdateAttach(attachInfo)
    end
    
    self.ItemClick = function(itemData)
        local attachInfo = {}
        attachInfo.str = LuaUIUtil.GetItemName(itemData.id)
        if ItemType.IsEquipById(itemData.id) then
            attachInfo.type = 'equip'           
        else
            attachInfo.type = 'item'
        end
        attachInfo.data = itemData
        ChatUICtrl.UpdateAttach(attachInfo)
    end
    
    return self
end

return CreateChatAdditionUICtrl()