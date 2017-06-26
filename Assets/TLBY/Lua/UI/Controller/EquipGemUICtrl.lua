---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateEquipGemUICtrl()
    local self = CreateCtrlBase()
    
    local itemTable = require "Logic/Scheme/common_item"
    local gemTable = require "Logic/Scheme/equipment_jewel"
    local attributeTable = (require "Logic/Scheme/equipment_base").Attribute
    local const = require "Common/constant"
    local equip_type_to_name = const.equip_type_to_name
    
    local gemList = {}
    local currentEquip = 0
    local trans = {[1]=1,[2]=2,[3]=4,[4]=5}
    local dragItem = 0
    local moveID = 0
    local posIndex = 0
    
    local GetIdByIndex = function(index)
        local ids = BagManager.GetItemIdsByType(const.TYPE_GEM)
        local count = index
        for i=1,#ids do
            count = count - BagManager.GetItemNumberById(ids[i])
            if count < 0 then
                return ids[i]
            end
        end
    end
    
    local GetGemEffect = function(gemID,level)
        for i=1,#gemTable.GemValue do
            if gemTable.GemValue[i].GemID == gemID and gemTable.GemValue[i].Level == level then
                return gemTable.GemValue[i].Num
            end
        end
        return 0
    end
    
    local GemPosInfo = function(index)
        local slotsData = GemManager.gemInfo[equip_type_to_name[currentEquip]].slots
        return slotsData[index]
    end
    
    local Contain = function(tb,value)
        for i=0,#tb do
            if tb[i] == value then
                return true
            end
        end   
        return false
    end
    
    local GetSuitPos = function(id)
        local config = itemTable.Item[id]
        local shapeList = gemTable.GemShape[tonumber(config.Para2)].ShapeNum
        if shapeList[2] == 3 then shapeList[1] = 2 shapeList[2] = 4  shapeList[3] = 5 end
        local suit = false
        for i=1,9 do
            if not((Contain(shapeList,1) and GemPosInfo(i)~=0 and GemPosInfo(i) ~= moveID) or
            (Contain(shapeList,2) and (i%3 == 0 or (GemPosInfo(i + 1)~=0 and GemPosInfo(i + 1) ~= moveID))) or 
            (Contain(shapeList,4) and (i+3 > 9 or (GemPosInfo(i + 3)~=0 and GemPosInfo(i + 3) ~= moveID))) or 
            (Contain(shapeList,5) and (i%3 == 0 or (GemPosInfo(i + 4)~=0 and GemPosInfo(i + 4) ~= moveID)))) then
                return i
            end
        end        
        return 0
    end
    
    local NotInserted = function(id)
        for i=1,9 do
            if GemPosInfo(i) > 0 then
                local config = itemTable.Item[id]        
                local para1 = string.split(config.Para1,'|')
                local type1 = tonumber(para1[1])
                config = itemTable.Item[GemPosInfo(i)]
                local para1 = string.split(config.Para1,'|')
                local type2 = tonumber(para1[1])
                if type1 == type2 then
                    return false
                end
            end
        end   
        return true
    end
    
    local UpdateItem = function(obj,index)
        local bg = obj.transform:FindChild('bg').gameObject
        local name = obj.transform:FindChild('name'):GetComponent('TextMeshProUGUI')
        local level = obj.transform:FindChild('level'):GetComponent('TextMeshProUGUI')
        local effect = obj.transform:FindChild('effect'):GetComponent('TextMeshProUGUI')
        local num = obj.transform:FindChild('num'):GetComponent('TextMeshProUGUI')
        local dark = obj.transform:FindChild('dark').gameObject
        local light = obj.transform:FindChild('light').gameObject
        local gem1 = obj.transform:FindChild('gem1').gameObject
        local gem2 = obj.transform:FindChild('gem2').gameObject
        local gem3 = obj.transform:FindChild('gem3').gameObject
        local gem4 = obj.transform:FindChild('gem4').gameObject
        
        local gemData  = gemList[index+1]
        if gemData == nil then 
            obj:SetActive(false)
            return
        else
            obj:SetActive(true)
        end
        num.text = gemData.num
        local id = gemData.id
        local shapeList = gemTable.GemShape[tonumber(itemTable.Item[id].Para2)].ShapeNum
        if shapeList[2] == 3 then shapeList[1] = 2 shapeList[2] = 4  shapeList[3] = 5 end

        local para1 = string.split(itemTable.Item[id].Para1,'|')
        local gemData = gemTable.GemType[tonumber(para1[1])]
        name.text = LuaUIUtil.GetTextByID(gemData,'name')
        level.text = '【'..tonumber(para1[2])..'】级'
        gem1:SetActive(Contain(shapeList,trans[1]))
        gem2:SetActive(Contain(shapeList,trans[2]))
        gem3:SetActive(Contain(shapeList,trans[3]))
        gem4:SetActive(Contain(shapeList,trans[4]))
        local attribute = gemData.AttriID
        effect.text = AttributeConst.GetAttributeNameByIndex(attribute)..'   +'..GetGemEffect(tonumber(para1[1]),tonumber(para1[2]))
        dark:SetActive(currentEquip ~= 0 and (gemData[equip_type_to_name[currentEquip]] ~= 1 or not NotInserted(id)))
        light:SetActive(currentEquip ~= 0 and dragItem == index+1)
        ClickEventListener.Get(bg).onClick = function() self.SelectGemItem(index+1) end
    end   
    
    local Close = function()
        UIManager.UnloadView(ViewAssets.EquipGemUI)
        UIManager.UnloadView(ViewAssets.EquipmentUI)
    end
    
    local Compose = function()
        local num = BagManager.GetItemNumberByType(const.TYPE_GEM)
        if num <=0 then
            UIManager.ShowNotice('你还没有获得宝石')
            UIManager.UnloadView(ViewAssets.EquipGemHandleUI)
            return
        end
        UIManager.PushView(ViewAssets.EquipGemHandleUI,nil,1)
    end
    
    local Polish = function()
        local num = BagManager.GetItemNumberByType(const.TYPE_GEM)
        if num <=0 then
            UIManager.ShowNotice('你还没有获得宝石')
            UIManager.UnloadView(ViewAssets.EquipGemHandleUI)
            return
        end
        UIManager.PushView(ViewAssets.EquipGemHandleUI,nil,2)
    end
    
    local SwitchEquip = function(index)
        if BagManager.equipments[equip_type_to_name[index]] == nil then
            UIManager.ShowNotice('尚未穿戴装备')
            return
        end        
        currentEquip = index
        moveID = 0
        for k,v in pairs(equip_type_to_name) do
            self.view['bg'..v]:SetActive(currentEquip == k)
        end
        self.view.equipPart:SetActive(false)
        self.view.gemPart:SetActive(true)
        self.view.equipPartName:GetComponent('TextMeshProUGUI').text = LuaUIUtil.EquipPartName(currentEquip)
        self.UpdateSlot()
    end
    
    local ResetWeapon = function()
        currentEquip = 0
        self.view.equipPart:SetActive(true)
        self.view.gemPart:SetActive(false)
        self.CancelClick()
        self.view.equipPartName:GetComponent('TextMeshProUGUI').text = '选择部位'
        self.RefreshGemList()
    end
    
    local InsertGem = function()
        if self.view.gemPart.activeSelf then
            if dragItem ==0 then
                UIManager.ShowNotice('没有符合条件的宝石')
                return
            end
            if posIndex == 0 then
                UIManager.ShowNotice('宝石形状不匹配剩余格子')
                return
            end
            self.view.dragBox:SetActive(true)
            self.view.btnConfirm:SetActive(true)
            self.view.btnCancel:SetActive(true)
            self.view.dragBox:GetComponent('RectTransform').anchoredPosition = self.view['gemBg'..posIndex]:GetComponent('RectTransform').anchoredPosition
            local id = gemList[dragItem].id
            local shapeList = gemTable.GemShape[tonumber(itemTable.Item[id].Para2)].ShapeNum
            if shapeList[2] == 3 then shapeList[1] = 2 shapeList[2] = 4  shapeList[3] = 5 end
            for i=1,4 do
                if Contain(shapeList,trans[i]) then
                    self.view['dragBox'..i]:SetActive(true)
                    local config = itemTable.Item[id]
                    local para1 = string.split(config.Para1,'|')
                    self.view['dragBox'..i]:GetComponent('Image').overrideSprite = ResourceManager.LoadSprite(string.format("EquipGemUI/%s", gemTable.GemType[tonumber(para1[1])].color))
                    self.view.btns:GetComponent('RectTransform').anchoredPosition = self.view['btnPos'..i]:GetComponent('RectTransform').anchoredPosition
                else
                    self.view['dragBox'..i]:SetActive(false)
                end
            end
            self.view.dragLine1:SetActive(self.view.dragBox1.activeSelf ~= self.view.dragBox2.activeSelf)
            self.view.dragLine2:SetActive(self.view.dragBox1.activeSelf ~= self.view.dragBox3.activeSelf)
            self.view.dragLine3:SetActive(self.view.dragBox3.activeSelf ~= self.view.dragBox4.activeSelf)
            self.view.dragLine4:SetActive(self.view.dragBox2.activeSelf ~= self.view.dragBox4.activeSelf)
        else
            UIManager.ShowNotice('先选择要镶嵌的装备')
        end
    end
    
    self.SelectGemItem = function(index)
        if not self.view.gemPart.activeInHierarchy then return end
        dragItem = index
        posIndex = GetSuitPos(gemList[dragItem].id)
        self.RefreshGemList()
    end
    
    self.uiCamera = nil
    
    self.onLoad = function()
		self.view.dragBox:SetActive(false)
        DragEventListener.Get(self.view.dragBox).onBeginDrag = self.OnBeginDrag
        DragEventListener.Get(self.view.dragBox).onDrag = self.OnDrag
        DragEventListener.Get(self.view.dragBox).onEndDrag = self.OnEndDrag
        for i=1,9 do
            self.AddClick(self.view['block'..i],function() self.ClearBlock(i) end)
            self.AddClick(self.view['gemIcon'..i],function() self.GemClick(i) end)
        end
        self.uiCamera = CameraManager.uiCamera
        self.AddClick(self.view.btnClose,Close)
        self.AddClick(self.view.btnCompose,Compose)
        self.AddClick(self.view.btnPolish,Polish)
		self.AddClick(self.view.btnEquipSelect,ResetWeapon)
        self.AddClick(self.view.btnInsert,InsertGem)
        self.AddClick(self.view.btnCancel,self.CancelClick)
        self.AddClick(self.view.btnConfirm,self.ConfirmClick)
        for k,v in pairs(equip_type_to_name)do
            self.AddClick(self.view[v],function() SwitchEquip(k) end)
        end
        self.RefreshGemList()
		self.view.equipPart:SetActive(true)
        self.view.gemPart:SetActive(false)
		UpdateBeat:Add(self.Update,self)
        --self.view.transform.anchoredPosition3D = Vector3.New(self.view.transform.anchoredPosition3D.x,self.view.transform.anchoredPosition3D.y,-200)
    end
	
	self.onUnload =function()
		UpdateBeat:Remove(self.Update,self)
	end
    
    
    self.Update = function()
        if not self.view.dragBox.activeSelf then return end
            
        local suit = not(posIndex < 1 or 
            (self.view.dragBox1.activeSelf and (GemPosInfo(posIndex)~=0 and GemPosInfo(posIndex) ~= moveID)) or
            (self.view.dragBox2.activeSelf and (posIndex%3 == 0 or (GemPosInfo(posIndex + 1)~=0 and GemPosInfo(posIndex + 1) ~= moveID))) or 
            (self.view.dragBox3.activeSelf and (posIndex+3 > 9 or (GemPosInfo(posIndex + 3)~=0 and GemPosInfo(posIndex + 3) ~= moveID))) or 
            (self.view.dragBox4.activeSelf and (posIndex%3 == 0 or (GemPosInfo(posIndex + 4)~=0 and GemPosInfo(posIndex + 4) ~= moveID))))
        local color = Color.red
        if suit then color = Color.green end
        for i = 1,9 do
            if posIndex == 0 then
                self.view['gemBg'..i]:GetComponent('Image').color = Color.white
            elseif self.view.dragBox2.activeSelf and posIndex%3 ~= 0 and i== posIndex+1 then
                self.view['gemBg'..i]:GetComponent('Image').color = color
            elseif self.view.dragBox3.activeSelf and posIndex+3 < 10 and i == posIndex+3 then
                self.view['gemBg'..i]:GetComponent('Image').color = color
            elseif self.view.dragBox4.activeSelf and posIndex%3 ~= 0 and posIndex+3 <10 and i==posIndex+4 then
                self.view['gemBg'..i]:GetComponent('Image').color = color
            elseif self.view.dragBox1.activeSelf and posIndex == i then
                self.view['gemBg'..i]:GetComponent('Image').color = color
            else
                self.view['gemBg'..i]:GetComponent('Image').color = Color.white
            end
        end
    end
    
    self.RefreshGemList = function()
        if not self.isLoaded then return end

        gemList = {}
        for k,v in pairs(BagManager.items) do    
            if v ~= nil  and itemTable.Item[v.id].Type == const.TYPE_GEM then
                local config = itemTable.Item[v.id]
                local para1 = string.split(config.Para1,'|')
                local gemData = gemTable.GemType[tonumber(para1[1])]
                if (currentEquip == 0 or gemData[equip_type_to_name[currentEquip]] == 1) then
                local itemdata = {pos = k,id = v.id,num = v.count}
                    table.insert(gemList,itemdata)
                    if dragItem == 0 and currentEquip ~= 0 and NotInserted(v.id) then
                        dragItem = #gemList
                        posIndex = GetSuitPos(v.id)
                    end
                end
            end
        end
        self.view.gemItem:SetActive(false)
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.gemItem,395,125,0,6,2)  
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#gemList,UpdateItem)       
    end
    
	local lastPos = nil
	self.OnBeginDrag = function(event)       
        local ret
        local position
        ret,position = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.view.dragBox.transform.parent, 
        event.position, self.uiCamera, 1)
        lastPos = position
	end
    
    self.OnDrag = function(event)
		if self.view.dragBox.activeSelf then
            posIndex = 0
            local ret
            local position
            ret,position = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.view.dragBox.transform.parent, 
                event.position, self.uiCamera, 1)
            self.view.dragBox:GetComponent('RectTransform').anchoredPosition = self.view.dragBox:GetComponent('RectTransform').anchoredPosition + (position - lastPos)
            lastPos = position
            for i = 1,9 do
                if Vector3.Distance(self.view.dragBox1.transform.position,self.view['gemBg'..i].transform.position) < 1 then
                    posIndex = i
                   break
                end
            end
        end
    end
    
    self.CancelClick = function()
        self.view.dragBox:SetActive(false)
        self.view.btnConfirm:SetActive(false)
        self.view.btnCancel:SetActive(false)
        if moveID ~= 0 then
            moveID = 0
            self.UpdateSlot()
        end
        for i = 1,9 do
            self.view['gemBg'..i]:GetComponent('Image').color = Color.white
        end
    end
    
    self.ConfirmClick = function()
        self.view.dragBox:SetActive(false)
        self.view.btnConfirm:SetActive(false)
        self.view.btnCancel:SetActive(false)
        posIndex = 0
        local gemID = 0
        if moveID > 0 then
            gemID = moveID
            local id = moveID
            local indexs = {}
            for i=1,9 do
                if id == GemPosInfo(i) then
                    table.insert(indexs,i)
                end
            end
            local data = {}
            data.equip_type = currentEquip
            data.slots = indexs
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GEM_REMOVE,data)
            UIManager.UnloadView(ViewAssets.EquipGemTipUI)
        else
            gemID = gemList[dragItem].id
        end
        local data = {}
        data.equip_type = currentEquip
        data.item_id = gemID
        data.slots = {}
        for i = 1,9 do
            if self.view['gemBg'..i]:GetComponent('Image').color == Color.green then
                table.insert(data.slots,i)
            end 
        end
        for i = 1,9 do
            self.view['gemBg'..i]:GetComponent('Image').color = Color.white
        end
        if #data.slots > 0 then
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GEM_INLAY ,data)
        end    
        moveID = 0        
    end
    
    local GetBlockIndex = function()
        local num = 0
        for i=1,9 do
            if GemPosInfo(i) < 0 then
                num = num + 1
            end
        end
        return 6 - num
    end
    
    self.ClearBlock = function(index)
        UIManager.PushView(ViewAssets.UnLockPetSkillTipUI)
        local unLockPetSkillTipUICtrl = UIManager.PushView(ViewAssets.UnLockPetSkillTipUI)
        local items = {}
        local openSlot = GetBlockIndex()
        if #gemTable.Openings[openSlot].cost1 > 1 then
            table.insert(items,gemTable.Openings[openSlot].cost1[1])
            table.insert(items,gemTable.Openings[openSlot].cost1[2])
        end
        if #gemTable.Openings[openSlot].cost2 > 1 then
            table.insert(items,gemTable.Openings[openSlot].cost2[1])
            table.insert(items,gemTable.Openings[openSlot].cost2[2])
        end
		local data = {}
		data.okHandler = self.SendClearBlock
		data.title = string.format('解锁%s第%d个宝石槽位？',LuaUIUtil.EquipPartName(currentEquip),openSlot)
		data.index = index
		data.items = items
		
		unLockPetSkillTipUICtrl.Show(data)
        

    end
    
    self.SendClearBlock = function(index)
        local data = {}
        data.equip_type = currentEquip
        data.slot = index
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GEM_OPEN_SLOT,data)
    end
    
    self.RemoveGem = function(index)
        local id = GemPosInfo(index)
        local indexs = {}
        for i=1,9 do
            if id == GemPosInfo(i) then
                table.insert(indexs,i)
            end
        end
        local data = {}
        data.equip_type = currentEquip
        data.slots = indexs
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GEM_REMOVE,data)
        UIManager.UnloadView(ViewAssets.EquipGemTipUI)
    end
    
    self.GemClick = function(index)  
        UIManager.PushView(ViewAssets.EquipGemTipUI,nil,GemPosInfo(index),'卸下',function() self.RemoveGem(index) end,'移动',function() self.MoveGem(index) end,self.view['gemIcon'..index].transform.position)
    end
    
    local GetMoveItemPos = function()
        local indexs = {}
        for i=1,9 do
            if GemPosInfo(i) == moveID then
                table.insert(indexs,i)
            end
        end
        if #indexs == 3 and indexs[1]+2 == indexs[2] then
            return indexs[1] -1
        end
        return indexs[1]
    end
    
    self.MoveGem = function(index)
        UIManager.UnloadView(ViewAssets.EquipGemTipUI)
        moveID = GemPosInfo(index)
        self.UpdateSlot()
        posIndex = GetMoveItemPos()
        self.view.dragBox:SetActive(true)
        self.view.btnConfirm:SetActive(true)
        self.view.btnCancel:SetActive(true)
        self.view.dragBox:GetComponent('RectTransform').anchoredPosition = self.view['gemBg'..posIndex]:GetComponent('RectTransform').anchoredPosition
        local shapeList = gemTable.GemShape[tonumber(itemTable.Item[moveID].Para2)].ShapeNum
        if shapeList[2] == 3 then shapeList[1] = 2 shapeList[2] = 4  shapeList[3] = 5 end
        for i=1,4 do
            self.view['dragBox'..i]:SetActive(Contain(shapeList,trans[i]))
        end
    end
    
    self.UpdateSlot = function()
        if not self.isLoaded or (not self.view.gemPart.activeInHierarchy) then return end
        dragItem = 0
        for i=1,9 do
            local posInfo = GemPosInfo(i)
            self.view['block'..i]:SetActive(posInfo == -1)
            self.view['gemIcon'..i]:SetActive(posInfo > 0 and posInfo ~= moveID)
            if posInfo > 0 and posInfo ~= moveID then
                local config = itemTable.Item[posInfo]
                local para1 = string.split(config.Para1,'|')
                self.view['gemIcon'..i]:GetComponent('Image').overrideSprite = ResourceManager.LoadSprite(string.format("EquipGemUI/%s", gemTable.GemType[tonumber(para1[1])].color))
            end
            local posI0 = GemPosInfo(i) or 0
            if posI0 < 0 then posI0 = 0 end
            if self.view['lineH'..i] then
                local posI1 = GemPosInfo(i+1) or 0
                if posI1 < 0 then posI1 = 0 end
                self.view['lineH'..i]:SetActive(posI0 ~= posI1)
            end
            if self.view['lineV'..i] then
                local posI3 = GemPosInfo(i+3) or 0
                if posI3 < 0 then posI3 = 0 end
                self.view['lineV'..i]:SetActive(posI0 ~= posI3)
            end
        end
        self.RefreshGemList()
    end
    
    return self
end


return CreateEquipGemUICtrl()