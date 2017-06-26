--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/20 0020
-- Time: 15:44
-- To change this template use File | Settings | File Templates.
--

require "UI/Controller/LuaCtrlBase"
require "UI/TextAnchor"
require "Logic/Bag/QualityConst"
require "UI/UIGrayMaterial"

local texttable = require "Logic/Scheme/common_char_chinese"
local itemtable = require "Logic/Scheme/common_item"
local refinetable = require "Logic/Scheme/equipment_refine"
local const = require "Common/constant"
local equipment_base = require "Logic/Scheme/equipment_base"
local localization = require "Common/basic/Localization"

local uitext = texttable.UIText
local itemconfigs = itemtable.Item
local equipconfigs = equipment_base.equipTemplate
local equip_type_to_name = const.equip_type_to_name
local PROPERTY_NAME_TO_INDEX = const.PROPERTY_NAME_TO_INDEX
local PROPERTY_INDEX_TO_NAME = const.PROPERTY_INDEX_TO_NAME
local equip_name_to_type = const.equip_name_to_type

local equipment_attribute_table = {}
for i,v in pairs(equipment_base.Attribute) do
    equipment_attribute_table[v.ID] = v
end

local equip_refine_cost = {}
for i,v in pairs(refinetable.Cost) do
    if equip_refine_cost[v.part] == nil then
        equip_refine_cost[v.part] = {}
    end
    equip_refine_cost[v.part][v.levelmin] = v
end

local function CreateEquipmentSmeltingUICtrl()
    local self = CreateCtrlBase()

    self.currentEquipmentPos =  0
    self.isSelectEquipment = true
    self.currentReplaceProperty = 0
    self.currentProperty = 0
    --选择洗练属性
    self.isSelectReplaceProperty = false
    --副装备替换属性
    local replacePropertys = {}
    --主装备属性
    local propertys = {}
    --可洗练装备
    local equipments = {}
    --初始装备区位置
    local yArrowPosition = -241
    local yScrollViewPosition = -241
    local yNoEquipmentPosition = -234
    local yChooseEquipPosition = -72
    --洗练后特效
    self.isReply = false
    --光球底部中心
    local glow_position1 = Vector3.New(11,-326,0)
    --光球到达标准位置
    local glow_position2 = Vector3.New(-135,0,0)
    --顶部平移
    local effectTopOffsetX = 260
    local effectTopOffsetY = -50
    --顶部光条标准位置
    local effectBornPosition = Vector3.New(-130,0,0)
    --底部光条位置1（小）
    local effectCompPosition1 = Vector3.New(3,-367,0)
    local effectCompScale1 = Vector3.New(68,80,68)
    --底部光条位置2（大）
    local effectCompPosition2 = Vector3.New(3,-347,0)
    local effectCompScale2 = Vector3.New(68,100,68)
    --洗练装备的属性条数
    local propcount = 0
    local effectTimer = nil
    local isBindCoin = true

    local function OnCloseBtnClick()
        UIManager.UnloadView(ViewAssets.EquipmentUI)
    end

    local function OnHelpBtnClick()
        UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
            ctrl.UpdateMsg(uitext[1101040].NR)
        end)
    end

    local function SmeltingBtnClickHandle()
        if BagManager.currentEquipSlot == "bag" then
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_REFINE_EQUIPMENT, {equip_pos= BagManager.currentSmeltingPos,item_pos=self.currentEquipmentPos,refine_attribute1=self.currentProperty,refine_attribute2=self.currentReplaceProperty})
        else
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_REFINE_EQUIPMENT, {equip_type=equip_name_to_type[BagManager.currentEquipSlot],item_pos=self.currentEquipmentPos,refine_attribute1=self.currentProperty,refine_attribute2=self.currentReplaceProperty})
        end
    end

    local function OnSmeltingBtnClick()
        local equipmentdata = nil
        if BagManager.currentEquipSlot == "bag" then
            equipmentdata = BagManager.items[BagManager.currentSmeltingPos]
        else
            equipmentdata = BagManager.equipments[BagManager.currentEquipSlot]
        end
        if equipmentdata == nil then
            return
        end

        local itemconfig = itemconfigs[equipmentdata.id]
        if itemconfig == nil then
            return
        end

        local refine_level = 0
        for i,v in pairs(equip_refine_cost[equip_type_to_name[itemconfig.Type]]) do
            if i <= itemconfig.LevelLimit and refine_level < i then
                refine_level = i
            end
        end
        if refine_level == 0 then
            return
        end

        local costItems = {}
        local costcfg = equip_refine_cost[equip_type_to_name[itemconfig.Type]][refine_level]
        if #costcfg.cost1 == 2 then
            table.insert(costItems,table.copy(costcfg.cost1))
        end
        if #costcfg.cost2 == 2 then
            table.insert(costItems,table.copy(costcfg.cost2))
        end
        if #costcfg.cost3 == 2 then
            table.insert(costItems,table.copy(costcfg.cost3))
        end
        if BagManager.CheckItemIsEnough(costItems) == false then
            return
        end
        BagManager.CheckBindCoinIsEnough(costItems,SmeltingBtnClickHandle)
    end

    local function StopSmeltingEffect()
        Timer.Remove(effectTimer)
        effectTimer = nil
        self.view.effectSmelting:SetActive(false)
        self.view.glow_common1:SetActive(false)
        self.view.glow_common2:SetActive(false)
        self.view.glow_common3:SetActive(false)
        self.view.xilian_burn:SetActive(false)
        self.view.xilian_comp:SetActive(false)
    end

    local function OnSmeltingReply(data)
        self.currentEquipmentPos =  0
        self.isSelectEquipment = true
        if data.result == 0 then
            StopSmeltingEffect()
            self.isReply = true
            self.view.effectSmelting:SetActive(true)
            self.view.xilian_comp:SetActive(true)
            if propcount < 8 then
                self.view.xilian_comp.transform.localPosition = effectCompPosition2
                self.view.xilian_comp.transform.localScale = effectCompScale2
            else
                self.view.xilian_comp.transform.localPosition = effectCompPosition1
                self.view.xilian_comp.transform.localScale = effectCompScale1
            end
            local function glow_fly()
                --self.view.xilian_comp:SetActive(false)
                local position1 = glow_position1 + Vector3.New(math.random(-100,100),math.random(-50,50),0)
                local position2 = glow_position1 + Vector3.New(math.random(-100,100),math.random(-50,50),0)
                local position3 = glow_position1 + Vector3.New(math.random(-100,100),math.random(-50,50),0)
                local target1 = glow_position2 + Vector3.New((self.currentProperty - 1)%2*260 + math.random(-50,50),-50*math.floor((self.currentProperty-1)/2),0)
                local target2 = glow_position2 + Vector3.New((self.currentProperty - 1)%2*260 + math.random(-50,50),-50*math.floor((self.currentProperty-1)/2),0)
                local target3 = glow_position2 + Vector3.New((self.currentProperty - 1)%2*260 + math.random(-50,50),-50*math.floor((self.currentProperty-1)/2),0)

                self.view.glow_common1:SetActive(true)
                self.view.glow_common2:SetActive(true)
                self.view.glow_common3:SetActive(true)
                Timer.Remove(effectTimer)
                local glow_count = 30
                local current_glow_count = 0
                effectTimer = Timer.Numberal(0.03,glow_count,function()
                    self.view.glow_common1.transform.localPosition = position1 + (target1 - position1)*(current_glow_count/glow_count)
                    self.view.glow_common2.transform.localPosition = position2 + (target2 - position2)*(current_glow_count/glow_count)
                    self.view.glow_common3.transform.localPosition = position3 + (target1 - position3)*(current_glow_count/glow_count)
                    current_glow_count = current_glow_count + 1
                    if current_glow_count >= glow_count then
                        Timer.Remove(effectTimer)
                        self.view.glow_common1:SetActive(false)
                        self.view.glow_common2:SetActive(false)
                        self.view.glow_common3:SetActive(false)
                        self.view.xilian_burn:SetActive(true)
                        self.view.xilian_burn.transform.localPosition = effectBornPosition + Vector3.New((self.currentProperty-1)%2*260,-50*math.floor((self.currentProperty-1)/2),0)
                        local refreshTimer = Timer.Delay(0.1,function()
                            self.isReply = false
                            self.UpdateView()
                        end)
                        effectTimer = Timer.Delay(1,function()
                            StopSmeltingEffect()
                            self.view.glow_common1.transform.localPosition = glow_position1
                            self.view.glow_common2.transform.localPosition = glow_position1
                            self.view.glow_common3.transform.localPosition = glow_position1
                        end)
                    end
                end)
            end
            effectTimer = Timer.Delay(0.3,function()
                glow_fly()
            end)
        end
    end

    local function OnReturnClick()
        self.currentEquipmentPos = 0
        self.isSelectEquipment = true
        self.UpdateView()
    end

    self.onLoad = function()
        --洗练按钮
        self.textSmeltingBtn = self.view.textsmelting:GetComponent("TextMeshProUGUI")
        --self.textSmeltingBtn.fontSize = 40
        --UIUtil.SetTextAlignment(self.textSmeltingBtn,TextAnchor.MiddleCenter)
        --self.textSmeltingBtn.color = Color.New(228/255,191/255,173/255)
        --UIUtil.AddTextOutline(self.view.textsmelting,Color.New(89/255,4/255,1/255))
        self.view.textsmelting:GetComponent("RectTransform").sizeDelta = Vector2.New(90,45)
        self.textSmeltingBtn.text = uitext[1115003].NR
        self.imgSmeltingBtn = self.view.btnsmelting:GetComponent("Image")
        UIUtil.AddButtonEffect(self.view.btnsmelting,nil,nil)

        --选择副装备
        self.textSelectEquipment = self.view.textchooseequipment:GetComponent("TextMeshProUGUI")
        --self.textSelectEquipment.fontSize = 35
        --self.textSelectEquipment.color = Color.New(223/255,200/255,181/255)
        --UIUtil.SetTextAlignment(self.textSelectEquipment,TextAnchor.MiddleCenter)
        --UIUtil.AddTextOutline(self.view.textchooseequipment,QualityConst.GetDarkOutlineColor())
        self.textSelectEquipmentTransform = self.view.textchooseequipment:GetComponent("RectTransform")
        self.textSelectEquipmentTransform.sizeDelta = Vector2.New(300,40)

        --选择替换属性
        self.textCurrentEquipLabel = self.view.textCurrentEquipLabel:GetComponent("TextMeshProUGUI")
        --self.textCurrentEquipLabel.fontSize = 35
        --self.textCurrentEquipLabel.color = Color.New(223/255,200/255,181/255)
        --UIUtil.SetTextAlignment(self.textCurrentEquipLabel,TextAnchor.MiddleCenter)
        --UIUtil.AddTextOutline(self.view.textCurrentEquipLabel,QualityConst.GetDarkOutlineColor())
        self.textCurrentEquipLabelTransform = self.view.textCurrentEquipLabel:GetComponent("RectTransform")
        self.textCurrentEquipLabelTransform.sizeDelta = Vector2.New(500,40)
        self.textCurrentEquipLabel.text = uitext[1116014].NR

        --洗练消耗
        self.textSmeltingCost = self.view.textsmeltingpay:GetComponent("TextMeshProUGUI")
        --无装备提示
        self.textNoEquipment = self.view.textnosmelting:GetComponent("TextMeshProUGUI")
        self.textNoEquipment.text = uitext[1116005].NR
        self.textNoEquipmentTransform = self.view.textnosmelting:GetComponent("RectTransform")
        --装备属性区
        self.smeltingTransform = self.view.smeltingui:GetComponent("RectTransform")
        --副装备区域
        self.scrollViewTransform = self.view.ScrollView:GetComponent("RectTransform")
        self.scrollViewContentTransform = self.view.Content:GetComponent("RectTransform")
        self.arrowTransform = self.view.bigarrow:GetComponent("RectTransform")
        --特效
        self.view.effectSmelting:SetActive(false)
        self.view.glow_common1.transform.localPosition = glow_position1
        self.view.glow_common2.transform.localPosition = glow_position1
        self.view.glow_common3.transform.localPosition = glow_position1

        ClickEventListener.Get(self.view.btnclose).onClick = OnCloseBtnClick
        -- ClickEventListener.Get(self.view.btnupgradestar).onClick = OnUpgradeStartTabClick
        -- ClickEventListener.Get(self.view.btnpagingstrengthen).onClick = OnStrengthenTabClick
        -- ClickEventListener.Get(self.view.gemgem).onClick = OnGemTabClick
        --ClickEventListener.Get(self.view.btnrules).onClick = OnHelpBtnClick
        ClickEventListener.Get(self.view.btnsmelting).onClick = OnSmeltingBtnClick
        ClickEventListener.Get(self.view.btnreturn).onClick = OnReturnClick

        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_REFINE_EQUIPMENT,OnSmeltingReply)
        if BagManager.currentEquipmentPos > 0 then
            self.currentEquipmentPos = BagManager.currentEquipmentPos
            self.isSelectEquipment = false
            BagManager.currentEquipmentPos = 0
        end
        --self.view.transform.anchoredPosition3D = Vector3.New(self.view.transform.anchoredPosition3D.x,self.view.transform.anchoredPosition3D.y,-200)
    end

    self.UpdateView = function()
        if self.isReply then
            return
        end

        local itemdata = nil
        if BagManager.currentEquipSlot == "bag" then
            itemdata = BagManager.items[BagManager.currentSmeltingPos]
        else
            itemdata = BagManager.equipments[BagManager.currentEquipSlot]
        end

        if itemdata == nil then
            return
        end

        local itemconfig = itemconfigs[itemdata.id]
        if itemconfig == nil then
            return
        end

        local equip_config = equipconfigs[itemdata.id]
        if equip_config == nil then
            return
        end

        local selectEquipData = nil
        if self.isSelectEquipment then
            self.textSelectEquipment.text = uitext[1116001].NR
            self.view.textsmeltingpay:SetActive(false)
            self.view.textsmelting:SetActive(false)
            self.view.btnsmelting:SetActive(false)
            self.view.btnreturn:SetActive(false)
        else
            self.textSelectEquipment.text = uitext[1116004].NR
            self.view.textnosmelting:SetActive(false)
            self.view.textsmeltingpay:SetActive(true)
            self.view.textsmelting:SetActive(true)
            self.view.btnsmelting:SetActive(true)
            self.view.btnreturn:SetActive(true)
            selectEquipData = BagManager.items[self.currentEquipmentPos]
            if selectEquipData == nil then
                return
            end
        end

        --装备名字
        self.textCurrentEquipLabel.text = localization.GetItemName(itemconfig.ID)
        --洗练属性

        local props = itemdata.additional_prop
        local sameProperty = 0
        if self.isSelectEquipment then
            self.currentProperty = 0
        else
            if self.currentReplaceProperty == 0 then
                self.currentProperty = 0
            end
            local selectReplaceProperty = selectEquipData.additional_prop[self.currentReplaceProperty]
            if selectReplaceProperty == nil then
                self.currentProperty = 0
            else
                --是否有同类别的
                if equipment_attribute_table[selectReplaceProperty[5]] ~= nil then
                    for i,v in pairs(props) do
                        if equipment_attribute_table[v[5]] ~= nil and equipment_attribute_table[v[5]].TypeID == equipment_attribute_table[selectReplaceProperty[5]].TypeID then
                            --如果刚刚选择了洗练属性，自动筛选
                            if self.isSelectReplaceProperty then
                                self.currentProperty = i
                            end
                            sameProperty = i
                            break
                        end
                    end
                    --如果刚刚选择了洗练属性，自动筛选
                    local nullslot = false
                    if sameProperty == 0 and self.isSelectReplaceProperty then
                        for j = 1,equip_config.ClearAttriMax,1 do
                            if props[j] == nil then
                                self.currentProperty = j
                                nullslot = true
                                break
                            end
                        end
                    end
                    --如果没有空槽位
                    if sameProperty == 0 and self.isSelectReplaceProperty and not nullslot then
                        for j = 1,equip_config.ClearAttriMax,1 do
                            if props[j] ~= nil and not props[j][3] then
                                self.currentProperty = j
                                break
                            end
                        end
                    end
                else
                    self.currentProperty = 0
                end
            end

        end
        propcount = 0
        for i= 1,equip_config.ClearAttriMax do
            propcount = propcount + 1
            if propertys[propcount] == nil then
                local current_propcount = propcount
                    ResourceManager.CreateUI("EquipmentSlotUI/EquipSmeltingPropertyUI",function(obj)
                    propertys[current_propcount] = {}
                    propertys[current_propcount].obj = obj
                    propertys[current_propcount].transform = propertys[current_propcount].obj:GetComponent("RectTransform")
                    propertys[current_propcount].table = propertys[current_propcount].obj:GetComponent("LuaBehaviour").luaTable
                    propertys[current_propcount].obj:SetActive(true)
                    propertys[current_propcount].transform:SetParent(self.smeltingTransform,false)
                    if current_propcount%2 == 1 then
                        propertys[current_propcount].transform.anchoredPosition3D = Vector3.New(90,355 - 88*(math.floor((current_propcount - 1)/2)))
                    else
                        propertys[current_propcount].transform.anchoredPosition3D = Vector3.New(525,355 - 88*(math.floor((current_propcount - 1)/2)))
                    end
                    propertys[current_propcount].table.SetData({data=props[current_propcount],pos=current_propcount,select=self.currentProperty,sameProperty = sameProperty})
                end)
            else
                propertys[propcount].obj:SetActive(true)
                propertys[propcount].transform:SetParent(self.smeltingTransform,false)
                if propcount%2 == 1 then
                    propertys[propcount].transform.anchoredPosition3D = Vector3.New(90,355 - 88*(math.floor((propcount - 1)/2)))
                else
                    propertys[propcount].transform.anchoredPosition3D = Vector3.New(525,355 - 88*(math.floor((propcount - 1)/2)))
                end
                propertys[propcount].table.SetData({data=props[propcount],pos=propcount,select=self.currentProperty,sameProperty = sameProperty})
            end
        end

        for i=propcount + 1,#propertys,1 do
            propertys[i].obj:SetActive(false)
        end
        local yOffset = 0
        if propcount < 8 then
            yOffset = 68
        end

        self.arrowTransform.anchoredPosition3D = Vector3.New(self.arrowTransform.anchoredPosition3D.x,yArrowPosition+yOffset,0)
        self.scrollViewTransform.anchoredPosition3D = Vector3.New(self.scrollViewTransform.anchoredPosition3D.x,yScrollViewPosition+yOffset/2,0)
        local sHeight = 300 + yOffset
        self.scrollViewTransform.sizeDelta = Vector3.New(self.scrollViewTransform.sizeDelta.x,sHeight)
        self.textNoEquipmentTransform.anchoredPosition3D = Vector3.New(self.textNoEquipmentTransform.anchoredPosition3D.x,yNoEquipmentPosition+yOffset/2,0)
        self.textSelectEquipmentTransform.anchoredPosition3D = Vector3.New(self.textSelectEquipmentTransform.anchoredPosition3D.x,yChooseEquipPosition+yOffset,0)
        local cHeight = sHeight
        if self.isSelectEquipment then
            local poss = nil
            if BagManager.currentEquipSlot == "bag" then
                poss = BagManager.GetSmeltingEquipmentsPosByPos(BagManager.currentSmeltingPos)
            else
                poss = BagManager.GetSmeltingEquipmentsPosByType(itemconfig.Type)
            end
            local equipcount = 0
            if #poss == 0 then
                self.view.textnosmelting:SetActive(true)
            else
                self.view.textnosmelting:SetActive(false)
                for i,v in pairs(poss) do
                    equipcount = equipcount + 1
                    if equipments[equipcount] == nil then
                        local current_equipcount = equipcount
                        local vv = v
                        ResourceManager.CreateUI("EquipmentSlotUI/EquipmentSmeltingItemUI",function(obj)
                            equipments[current_equipcount] = {}
                            equipments[current_equipcount].obj = obj
                            equipments[current_equipcount].transform = equipments[current_equipcount].obj:GetComponent("RectTransform")
                            equipments[current_equipcount].table = equipments[current_equipcount].obj:GetComponent("LuaBehaviour").luaTable
                            equipments[current_equipcount].obj:SetActive(true)
                            equipments[current_equipcount].transform:SetParent(self.scrollViewContentTransform,false)
                            if current_equipcount%3 == 1 then
                                equipments[current_equipcount].transform.anchoredPosition3D = Vector3.New(-290,-100 - 180*(math.floor((current_equipcount - 1)/3)))
                            elseif current_equipcount%3 == 2 then
                                equipments[current_equipcount].transform.anchoredPosition3D = Vector3.New(0,-100 - 180*(math.floor((current_equipcount - 1)/3)))
                            else
                                equipments[current_equipcount].transform.anchoredPosition3D = Vector3.New(290,-100 - 180*(math.floor((current_equipcount - 1)/3)))
                            end
                            equipments[current_equipcount].table.SetData({pos=vv})
                        end)
                    else
                        equipments[equipcount].obj:SetActive(true)
                        equipments[equipcount].transform:SetParent(self.scrollViewContentTransform,false)
                        if equipcount%3 == 1 then
                            equipments[equipcount].transform.anchoredPosition3D = Vector3.New(-290,-100 - 180*(math.floor((equipcount - 1)/3)))
                        elseif equipcount%3 == 2 then
                            equipments[equipcount].transform.anchoredPosition3D = Vector3.New(0,-100 - 180*(math.floor((equipcount - 1)/3)))
                        else
                            equipments[equipcount].transform.anchoredPosition3D = Vector3.New(290,-100 - 180*(math.floor((equipcount - 1)/3)))
                        end
                        equipments[equipcount].table.SetData({pos=v})
                    end
                end
                cHeight = 20 + math.ceil(equipcount/3)*180
                if cHeight < sHeight then
                    cHeight = sHeight
                end
            end
            for i = equipcount + 1,#equipments,1 do
                equipments[i].obj:SetActive(false)
            end
            for i = 1,#replacePropertys,1 do
                replacePropertys[i].obj:SetActive(false)
            end
        else
            local replaceprops = selectEquipData.additional_prop
            propcount = 0
            for i,v in pairs(replaceprops) do
                propcount = propcount + 1
                if replacePropertys[propcount] == nil then
                    local current_propcount = propcount
                    local pos = i
                    ResourceManager.CreateUI("EquipmentSlotUI/EquipSmeltingReplacePropertyUI",function(obj)
                        replacePropertys[current_propcount] = {}
                        replacePropertys[current_propcount].obj = obj
                        replacePropertys[current_propcount].transform = replacePropertys[current_propcount].obj:GetComponent("RectTransform")
                        replacePropertys[current_propcount].table = replacePropertys[current_propcount].obj:GetComponent("LuaBehaviour").luaTable
                        replacePropertys[current_propcount].obj:SetActive(true)
                        replacePropertys[current_propcount].transform:SetParent(self.scrollViewContentTransform,false)
                        if current_propcount%2 == 1 then
                            replacePropertys[current_propcount].transform.anchoredPosition3D = Vector3.New(-213,-51 - 88*(math.floor((current_propcount - 1)/2)))
                        else
                            replacePropertys[current_propcount].transform.anchoredPosition3D = Vector3.New(213,-51 - 88*(math.floor((current_propcount - 1)/2)))
                        end
                        --已有同一属性，并且比较好
                        local same = false
                        for k,p in pairs(props) do
                            if p[5] == v[5] and v[2] <= p[2] then
                                same = true
                                break
                            end
                        end
                        replacePropertys[current_propcount].table.SetData({data=replaceprops[current_propcount],pos=pos,select=self.currentReplaceProperty,same=same})
                    end)
                else
                    replacePropertys[propcount].obj:SetActive(true)
                    replacePropertys[propcount].transform:SetParent(self.scrollViewContentTransform,false)
                    if propcount%2 == 1 then
                        replacePropertys[propcount].transform.anchoredPosition3D = Vector3.New(-213,-51 - 88*(math.floor((propcount - 1)/2)))
                    else
                        replacePropertys[propcount].transform.anchoredPosition3D = Vector3.New(213,-51 - 88*(math.floor((propcount - 1)/2)))
                    end
                    --已有同一属性，并且比较好
                    local same = false
                    for k,p in pairs(props) do
                        if p[5] == v[5] and v[2] <= p[2] then
                            same = true
                            break
                        end
                    end
                    replacePropertys[propcount].table.SetData({data=replaceprops[propcount],pos=i,select=self.currentReplaceProperty,same=same})
                end
            end
            cHeight = 20 + math.ceil(propcount/2)*88
                if cHeight < sHeight then
                    cHeight = sHeight
                end
            for i = propcount+1,#replacePropertys,1 do
                replacePropertys[i].obj:SetActive(false)
            end
            for i = 1,#equipments,1 do
                equipments[i].obj:SetActive(false)
            end

            --消耗
            local refine_level = 0
            for i,v in pairs(equip_refine_cost[equip_type_to_name[itemconfig.Type]]) do
                if i <= itemconfig.LevelLimit and refine_level < i then
                    refine_level = i
                end
            end
            if refine_level > 0 then
                local canOperate = true
                local textCost = uitext[1116002].NR
                local costitemconfig = nil
                local costcfg = equip_refine_cost[equip_type_to_name[itemconfig.Type]][refine_level]
                if #costcfg.cost1 == 2 then
                    costitemconfig = itemconfigs[costcfg.cost1[1]]
                    if costitemconfig ~= nil then
                        if BagManager.GetItemNumberById(costcfg.cost1[1]) < costcfg.cost1[2] then
                            textCost = textCost..string.format(uitext[1116012].NR,localization.GetItemName(costitemconfig.ID),costcfg.cost1[2])
                            canOperate = false
                        else
                            textCost = textCost..string.format(uitext[1116013].NR,localization.GetItemName(costitemconfig.ID),costcfg.cost1[2])
                        end
                    end
                end
                if #costcfg.cost2 == 2 then
                    costitemconfig = itemconfigs[costcfg.cost2[1]]
                    if costitemconfig ~= nil then
                        if BagManager.GetItemNumberById(costcfg.cost2[1]) < costcfg.cost2[2] then
                            textCost = textCost..string.format(uitext[1116012].NR,localization.GetItemName(costitemconfig.ID),costcfg.cost2[2])
                            canOperate = false
                        else
                            textCost = textCost..string.format(uitext[1116013].NR,localization.GetItemName(costitemconfig.ID),costcfg.cost2[2])
                        end
                    end
                end
                if #costcfg.cost3 == 2 then
                    costitemconfig = itemconfigs[costcfg.cost3[1]]
                    if costitemconfig ~= nil then
                        if BagManager.GetItemNumberById(costcfg.cost3[1]) < costcfg.cost3[2] then
                            textCost = textCost..string.format(uitext[1116012].NR,localization.GetItemName(costitemconfig.ID),costcfg.cost3[2])
                            canOperate = false
                        else
                            textCost = textCost..string.format(uitext[1116013].NR,localization.GetItemName(costitemconfig.ID),costcfg.cost3[2])
                        end
                    end
                end
                self.textSmeltingCost.text = textCost
                if canOperate then
                    self.textSmeltingBtn.material = nil
                    self.imgSmeltingBtn.material = nil
                else
                    self.textSmeltingBtn.material = UIGrayMaterial.GetUIGrayMaterial()
                    self.imgSmeltingBtn.material = UIGrayMaterial.GetUIGrayMaterial()
                end
            end
        end
        self.scrollViewContentTransform.sizeDelta = Vector2.New(self.scrollViewContentTransform.sizeDelta.x,cHeight)
    end

    self.SetReplaceProperty = function(prop)
        self.isSelectReplaceProperty = true
        self.currentReplaceProperty = prop
        self.UpdateView()
    end

    self.SetProperty = function(prop)
        self.isSelectReplaceProperty = false
        self.currentProperty = prop
        self.UpdateView()
    end

    self.onUnload = function()
        self.isReply = false
        self.isSelectEquipment = true
        self.currentEquipmentPos = 0
        if BagManager.currentEquipSlot == "bag" then
            BagManager.currentEquipSlot = "Weapon"
        end

        for i,v in pairs(replacePropertys) do
            RecycleObject(v.obj)
        end
        replacePropertys = {}
        for i,v in pairs(propertys) do
            RecycleObject(v.obj)
        end
        propertys = {}
        for i,v in pairs(equipments) do
            RecycleObject(v.obj)
        end
        equipments = {}
    end

    return self
end

return CreateEquipmentSmeltingUICtrl()

