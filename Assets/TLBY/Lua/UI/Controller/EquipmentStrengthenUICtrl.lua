--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/20 0020
-- Time: 15:43
-- To change this template use File | Settings | File Templates.
--

require "UI/Controller/LuaCtrlBase"
require "UI/TextAnchor"
require "Logic/Bag/QualityConst"
require "Common/basic/Timer"
require "math"
require "UI/UIGrayMaterial"

local texttable = require "Logic/Scheme/common_char_chinese"
local itemtable = require "Logic/Scheme/common_item"
local strengthentable = require "Logic/Scheme/equipment_strengthen"
local const = require "Common/constant"
local localization = require "Common/basic/Localization"
local equipment_base = require "Logic/Scheme/equipment_base"
local equipment_strengthen_config = require "Logic/configs/equipment_strengthen_config"

local uitext = texttable.UIText
local itemconfigs = itemtable.Item
local strengthencost = strengthentable.Strengthstage
local advancecost = strengthentable.Cost
local equip_type_to_name = const.equip_type_to_name
local PROPERTY_NAME_TO_INDEX = const.PROPERTY_NAME_TO_INDEX
local PROPERTY_INDEX_TO_NAME = const.PROPERTY_INDEX_TO_NAME
local equip_name_to_type = const.equip_name_to_type

local strengthen_cost_table = {}
for i,v in pairs(strengthencost) do
	if strengthen_cost_table[v.stage] == nil then
		strengthen_cost_table[v.stage] = {}
	end
	strengthen_cost_table[v.stage][v.level] = v
end

local advance_cost_table = {}
for i,v in pairs(advancecost) do
    advance_cost_table[v.stage] = v
end

local equipment_base_attributes = {}
for _,v in pairs(equipment_base.Attribute) do
    equipment_base_attributes[v.ID] = v
end

local function get_current_and_next_strengthen_addition(part,current_stage,next_stage,current_level,next_level,prop,value)
    local strengthen_value = 0
    local strengthen_value2 = 0
    for i=1,current_stage,1 do
        local fixed = 0
        local percent = 0
        local addition_cfg = equipment_strengthen_config.get_strengthen_addition(part,i,prop)
        if addition_cfg ~= nil then
            if i == current_stage then
                fixed = fixed + addition_cfg.fixed*current_level
                percent = percent + addition_cfg.percent*current_level
            else
                fixed = fixed + addition_cfg.fixed*MAX_STRENGTHEN_LEVEL
                percent = percent + addition_cfg.percent*MAX_STRENGTHEN_LEVEL
            end
        end
        strengthen_value = value + fixed + math.floor(value*percent/100)
    end

    for i=1,next_stage,1 do
        local fixed = 0
        local percent = 0
        local addition_cfg = equipment_strengthen_config.get_strengthen_addition(part,i,prop)
        if addition_cfg ~= nil then
            if i == next_stage then
                fixed = fixed + addition_cfg.fixed*next_level
                percent = percent + addition_cfg.percent*next_level
            else
                fixed = fixed + addition_cfg.fixed*MAX_STRENGTHEN_LEVEL
                percent = percent + addition_cfg.percent*MAX_STRENGTHEN_LEVEL
            end
        end
        strengthen_value2 = value + fixed + math.floor(value*percent/100)
    end
    return strengthen_value,strengthen_value2
end

local function CreateEquipmentStrengthenUICtrl()
    local self = CreateCtrlBase()
    self.isReply = false
    local curSelectStrengthenItemId = 0
    local curSelectBlessItemId = 0
    local blessSelect = true
    --按钮效果
    local btnTimer = nil
    local strengthenResultTimer = nil
    --强化回包使用
    local useBless = false

    --光球位置
    local glow_position2 = Vector3.New(146.6,-273,0)
    local glow_position1 = Vector3.New(-128.5,-273,0)
    local glow_position = Vector3.New(3,-3,0)

    local function OnCloseBtnClick()
        UIManager.UnloadView(ViewAssets.EquipmentUI)
    end

    local function StrengthenHandle()
        local bless_id = 0
        if blessSelect then
            local blessItemConfig = itemconfigs[curSelectBlessItemId]
            if blessItemConfig then
                local blessItemNumber = BagManager.GetItemNumberById(blessItemConfig.ID)
                if blessItemNumber >= 1 then
                    bless_id = blessItemConfig.ID
                    useBless = true
                end
            end
        end
        if bless_id > 0 then
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_STRENGTHEN_EQUIPMENT, {equip_type=equip_name_to_type[BagManager.currentEquipSlot],strengthen_id=curSelectStrengthenItemId,bless_id=bless_id})
        else
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_STRENGTHEN_EQUIPMENT, {equip_type=equip_name_to_type[BagManager.currentEquipSlot],strengthen_id=curSelectStrengthenItemId})
        end
    end

    local CancelStrengthenHandle = function()
        BagManager.isBindCoin = true
    end

    local function OnStrengthenBtnClick()
        if self.isReply then
            return
        end

        useBless = false
        local stage = 1
        local level = 0
        if BagManager.equipment_strengthen and BagManager.equipment_strengthen[BagManager.currentEquipSlot] then
            stage = BagManager.equipment_strengthen[BagManager.currentEquipSlot].stage
            level = BagManager.equipment_strengthen[BagManager.currentEquipSlot].level
        end
        if level >= MAX_STRENGTHEN_LEVEL then
            return
        end

        local strengthen_cost_config = strengthen_cost_table[stage][level]
        if strengthen_cost_config == nil then
            return
        end

         local strengthenItemConfig = itemconfigs[curSelectStrengthenItemId]
        if strengthenItemConfig == nil then
            UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
                ctrl.UpdateMsg(uitext[1115022].NR)
            end)
            return
        end

        local strengthenItemNumber = BagManager.GetItemNumberById(curSelectStrengthenItemId)
        if strengthenItemNumber < strengthen_cost_config.number then
            UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
                ctrl.UpdateMsg(string.format(uitext[1115016].NR,localization.GetItemName(curSelectStrengthenItemId)))
            end)
            return
        end

        if BagManager.GetItemNumberById(strengthen_cost_config.silver[1]) < strengthen_cost_config.silver[2] then
            if BagManager.GetTotalCoin() < strengthen_cost_config.silver[2] then
                UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
                    ctrl.UpdateMsg(string.format(uitext[1115016].NR,uitext[1101031].NR))
                end)
                return
            end
            if BagManager.isBindCoin == true then
                BagManager.isBindCoin = false
                UIManager.ShowDialog(BagManager.GetBindCoinNotEnoughString(strengthen_cost_config.silver[2]),uitext[1101006].NR,uitext[1101007].NR,StrengthenHandle,CancelStrengthenHandle)
                return
            else
                StrengthenHandle()
            end
            return
        end

        StrengthenHandle()
    end

    local function OnAdvanceBtnClick()
        if self.isReply then
            return
        end
        useBless = false
        local data = {}
        data.equip_type = equip_name_to_type[BagManager.currentEquipSlot]
        local stage = 1
        local level = 0
        if BagManager.equipment_strengthen and BagManager.equipment_strengthen[BagManager.currentEquipSlot] then
            stage = BagManager.equipment_strengthen[BagManager.currentEquipSlot].stage
            level = BagManager.equipment_strengthen[BagManager.currentEquipSlot].level
        end

        if level < MAX_STRENGTHEN_LEVEL then
            return
        end

        --最大等阶
        if stage >= MAX_STRENGTHEN_STAGE then
            UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
                ctrl.UpdateMsg(uitext[1115023].NR)
            end)
            return
        end

        local advance_cost_config = advance_cost_table[stage]
        if advance_cost_config == nil then
            return
        end

        local costs = {}
        if advance_cost_config.cost1[1] > 0 then
            costs[advance_cost_config.cost1[1]] = advance_cost_config.cost1[2]
        end

        if advance_cost_config.cost2[1] > 0 then
            costs[advance_cost_config.cost2[1]] = advance_cost_config.cost2[2]
        end
        if BagManager.CheckItemIsEnoughEx(costs) == false then
            return
        end
        BagManager.CheckBindCoinIsEnoughEx(costs,function()
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_STRENGTHEN_EQUIPMENT, {equip_type=equip_name_to_type[BagManager.currentEquipSlot]})
        end)
    end

    -- local function OnUpgradeStartTabClick()
        -- if UIManager.GetCtrl(ViewAssets.EquipmentUI).isLoaded then
            -- UIManager.GetCtrl(ViewAssets.EquipmentUI).ShowTab(EquipmentUITab.UPGRADESTAR)
        -- end
        -- UIManager.UnloadView(ViewAssets.EquipmentStrengthenUI)
    -- end

    -- local function OnSmeltingTabClick()
        -- if UIManager.GetCtrl(ViewAssets.EquipmentUI).isLoaded then
            -- UIManager.GetCtrl(ViewAssets.EquipmentUI).ShowTab(EquipmentUITab.SMELTING)
        -- end
        -- UIManager.UnloadView(ViewAssets.EquipmentStrengthenUI)
    -- end

    -- local function OnGemTabClick()
        -- if UIManager.GetCtrl(ViewAssets.EquipmentUI).isLoaded then
            -- UIManager.PushView(ViewAssets.EquipGemUI)
            -- UIManager.UnloadView(ViewAssets.EquipmentStrengthenUI)
        -- end
    -- end

    local function OnSelectStrengthenItemHandler(data)
        curSelectStrengthenItemId = data
        self.UpdateView()
    end

    --强化石
    local function OnAddStrengthenItem1()
        UIManager.PushView(ViewAssets.PurchaseUI,function()
            UIManager.GetCtrl(ViewAssets.PurchaseUI).UpdateData({items=BagManager.GetItemIdsByType(const.TYPE_EQUIP_STRENGTHEN),okHandler=OnSelectStrengthenItemHandler})
        end)
    end
    local function OnSelectBlessItemHandler(data)
        curSelectBlessItemId = data
        self.UpdateView()
    end
    --祝福石
    local function OnAddStrengthenItem2()
        UIManager.ShowNotice(texttable.UIText[1101040].NR)
--        UIManager.PushView(ViewAssets.PurchaseUI)
--        UIManager.GetCtrl(ViewAssets.PurchaseUI).UpdateData({items=BagManager.GetItemIdsByType(const.TYPE_EQUIP_STRENGTHEN_BLESS),okHandler=OnSelectBlessItemHandler})
    end
    --进阶消耗1
    local function OnAddStrengthenItem3()
        local advance_cost_config = advance_cost_table[BagManager.equipment_strengthen[BagManager.currentEquipSlot].stage]
        if advance_cost_config then
            UIManager.GetCtrl(ViewAssets.MallUI).OpenUI(advance_cost_config.cost1[1])
        end
    end
    --进阶消耗2
    local function OnAddStrengthenItem4()
    end

    local function OnHelpBtnClick()
        UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
            ctrl.UpdateMsg(texttable.UIText[1101040].NR)
        end)
    end

    local function StopStrengthenEffect()
        Timer.Remove(strengthenResultTimer)
        self.view.qianghua_succeed:SetActive(false)
        self.view.glow_common1:SetActive(false)
        self.view.glow_common2:SetActive(false)
        self.view.qianghua_defeat:SetActive(false)
        self.view.effectStrengthen:SetActive(false)
        self.view.imgStrengthensuccess:SetActive(false)
        self.view.imgStrengthenfailure:SetActive(false)
    end

    local function OnEquipmentStrengthenReply(data)
        if data.result == 0 then
            self.isReply = true
            local current_stage = 1
            local current_level = 0
            if BagManager.equipment_strengthen and BagManager.equipment_strengthen[BagManager.currentEquipSlot] then
                current_stage = BagManager.equipment_strengthen[BagManager.currentEquipSlot].stage
                current_level = BagManager.equipment_strengthen[BagManager.currentEquipSlot].level
            end
            local function ShowResultEffectOver()
                Timer.Remove(strengthenResultTimer)
                self.view.qianghua_succeed:SetActive(false)
                self.view.qianghua_defeat:SetActive(false)
                if data.success == 0 then
                    if data.drop_level > 0 then
                        UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
                            ctrl.UpdateMsg(string.format(texttable.UIText[1115021].NR,data.drop_level))
                        end)
                    end
                end
                if data.stage ~= current_stage or data.level ~= current_level then
                    --属性增强
                    self.textAdvanceBeforeAttribute1.text = ""
                    self.textAdvanceOverAttribute1.text = ""
                    self.textAdvanceBeforeAttribute2.text = ""
                    self.textAdvanceOverAttribute2.text = ""
                    self.textAdvanceBeforeAttribute3.text = ""
                    self.textAdvanceOverAttribute3.text = ""
                    self.textStrengthenBeforeAttribute1.text = ""
                    self.textStrengthenOverAttribute1.text = ""
                    self.textStrengthenBeforeAttribute2.text = ""
                    self.textStrengthenOverAttribute2.text = ""
                    self.textStrengthenBeforeAttribute3.text = ""
                    self.textStrengthenOverAttribute3.text = ""
                    local count = 0
                    local base_prop = {}
                    for basename,basevalue in pairs(BagManager.equipments[BagManager.currentEquipSlot].base_prop) do
                        if not AttributeConst.IsElementAttribute(basename) then
                            count = count + 1
                            table.insert(base_prop,{prop=basename,value=basevalue})
                        end
                    end

                    if count > 1 then
                        table.sort(base_prop,AttributeConst.BasePropSort)
                    end
                    local value = {}
                    local strengthen = {}
                    for index =1,count,1 do
                        value[index],strengthen[index] = get_current_and_next_strengthen_addition(BagManager.currentEquipSlot,current_stage,data.stage,current_level,data.level,base_prop[index].prop,base_prop[index].value)
                    end
                    local index = 0
                    local effect_count = 0
                    strengthenResultTimer = Timer.Numberal(0.03,50,function()
                        for index =1,count,1 do
                            self["textStrengthenBeforeAttribute"..index].text = AttributeConst.GetAttributeNameByIndex(base_prop[index].prop).."  +"..value[index] + math.floor(effect_count*(strengthen[index] - value[index]) / 50)
                            self["textStrengthenOverAttribute"..index].text = AttributeConst.GetAttributeNameByIndex(base_prop[index].prop).."  +"..strengthen[index]
                            self["textAdvanceBeforeAttribute"..index].text = AttributeConst.GetAttributeNameByIndex(base_prop[index].prop).."  +"..value[index] + math.floor(effect_count*(strengthen[index] - value[index]) / 50)
                            self["textAdvanceOverAttribute"..index].text = AttributeConst.GetAttributeNameByIndex(base_prop[index].prop).."  +"..strengthen[index]
                        end
                        effect_count = effect_count + 1
                        if effect_count == 50 then
                            self.isReply = false
                            self.UpdateView()
                            Timer.Remove(strengthenResultTimer)
                            StopStrengthenEffect()
                        end
                    end)
                else
                    self.isReply = false
                    self.UpdateView()
                    Timer.Remove(strengthenResultTimer)
                    strengthenResultTimer = Timer.Delay(1,function()
                        StopStrengthenEffect()
                    end)
                end
            end
            StopStrengthenEffect()
            --强化特效
            if current_level < MAX_STRENGTHEN_LEVEL then
                self.view.effectStrengthen:SetActive(true)
                self.view.glow_common1:SetActive(true)
                self.view.glow_common1.transform.localPosition = glow_position1
                if useBless then
                    self.view.glow_common2:SetActive(true)
                    self.view.glow_common2.transform.localPosition = glow_position2
                end
                local glow_count = 21
                local glow_current_count = 0
                strengthenResultTimer = Timer.Numberal(0.03,glow_count,function()
                    self.view.glow_common1.transform.localPosition = glow_position1 + (glow_position - glow_position1)*(glow_current_count/glow_count)
                    self.view.glow_common2.transform.localPosition = glow_position2 + (glow_position - glow_position2)*(glow_current_count/glow_count)
                    glow_current_count = glow_current_count + 1
                    if glow_current_count >= glow_count then
                        Timer.Remove(strengthenResultTimer)
                        self.view.glow_common1:SetActive(false)
                        self.view.glow_common2:SetActive(false)
                        if data.success == 1 then
                            self.view.qianghua_succeed:SetActive(true)
                            strengthenResultTimer = Timer.Delay(0.8,function()
                                self.view.imgStrengthensuccess:SetActive(true)
                                ShowResultEffectOver()
                            end)
                        else
                            self.view.qianghua_defeat:SetActive(true)
                            strengthenResultTimer = Timer.Delay(0.8,function()
                                self.view.imgStrengthenfailure:SetActive(true)
                                ShowResultEffectOver()
                            end)
                        end
                    end
                end)
            else
                ShowResultEffectOver()
            end
        end
        --self.UpdateView()
    end

    local function OnSelectBlessItem()
        UIManager.ShowNotice(texttable.UIText[1101040].NR)
--        if blessSelect then
--            blessSelect = false
--        else
--            blessSelect = true
--        end
--        self.UpdateView()
    end

    local function OnStrengthenEquipmentClick()
        BagManager.ShowItemTips({from=ItemTipsFromType.EQUIPMENT,pos=BagManager.currentEquipSlot,item_data=BagManager.equipments[BagManager.currentEquipSlot]},true)
    end

    self.onLoad = function()
        --强化界面
        --强化按钮
        self.textStrengthenBtn = self.view.textdetermine:GetComponent("TextMeshProUGUI")
        --self.textStrengthenBtn.fontSize = 40
        --UIUtil.SetTextAlignment(self.textStrengthenBtn,TextAnchor.MiddleCenter)
        --UIUtil.AddTextOutline(self.view.textdetermine,Color.New(255/255,222/255,191/255))
        self.view.textdetermine:GetComponent("RectTransform").sizeDelta = Vector2.New(90,45)
        self.textStrengthenBtn.text = uitext[1115001].NR
        self.imgStrengthenBtn = self.view.btndetermine:GetComponent("Image")
        UIUtil.AddButtonEffect(self.view.btndetermine,nil,nil)
        --成功率
        self.textStrengthenSuccess = self.view.Strengthenstonetitlename:GetComponent("TextMeshProUGUI")
        --self.textStrengthenSuccess.fontSize = 26
        --UIUtil.SetTextAlignment(self.textStrengthenSuccess,TextAnchor.MiddleCenter)
        --强化前
        --强化等级
        self.textStrengthenBeforeLevel = self.view.textstrengthenlevel1:GetComponent("TextMeshProUGUI")
        --self.textStrengthenBeforeLevel.fontSize = 26
        --UIUtil.SetTextAlignment(self.textStrengthenBeforeLevel,TextAnchor.MiddleCenter)
        --属性1
        self.textStrengthenBeforeAttribute1 = self.view.textstrengthenattribute1:GetComponent("TextMeshProUGUI")
        --属性2
        self.textStrengthenBeforeAttribute2 = self.view.textstrengthenattribute3:GetComponent("TextMeshProUGUI")
        --属性3
        self.textStrengthenBeforeAttribute3 = self.view.textstrengthenattribute5:GetComponent("TextMeshProUGUI")
        --强化后
        --强化等级
        self.textStrengthenOverLevel = self.view.textstrengthenlevel2:GetComponent("TextMeshProUGUI")
        --属性1
        self.textStrengthenOverAttribute1 = self.view.textstrengthenattribute2:GetComponent("TextMeshProUGUI")
        --属性2
        self.textStrengthenOverAttribute2 = self.view.textstrengthenattribute4:GetComponent("TextMeshProUGUI")
        --属性3
        self.textStrengthenOverAttribute3 = self.view.textstrengthenattribute6:GetComponent("TextMeshProUGUI")
        --强化石说明
        self.textStrengthenDescription = self.view.Strengthenstonedescribe:GetComponent("TextMeshProUGUI")
        self.textStrengthenDescription.text = uitext[1115009].NR
        --强化石数量
        self.textStrengthenNumber = self.view.textstrengthencost2:GetComponent("TextMeshProUGUI")
        --强化石图标
        self.imgStrengthenIcon = self.view.StrengthenItemIcon2:GetComponent("Image")
        self.imgStrengthenQuality = self.view.StrengthenItemQuality2:GetComponent("Image")
        --强化石加号
        --祝福石说明
        self.textBlessDescription = self.view.Strengthenoperatordescribe:GetComponent("TextMeshProUGUI")
        self.textBlessDescription.text = uitext[1115013].NR
        --祝福石数量
        self.textBlessNumber = self.view.textstrengthencost3:GetComponent("TextMeshProUGUI")

        --祝福石图标
        self.imgBlessIcon = self.view.StrengthenItemIcon3:GetComponent("Image")
        self.imgBlessQuality = self.view.StrengthenItemQuality3:GetComponent("Image")
        --祝福石加号
        --银币消耗
        self.textSilverCost = self.view.Strengthenstonepay:GetComponent("TextMeshProUGUI")
        --装备图标
        self.imgStrengthenEquipIcon = self.view.StrengthenItemIcon1:GetComponent("Image")
        self.imgStrengthenEquipQuality = self.view.StrengthenItemQuality1:GetComponent("Image")
        --进阶界面
        --进阶按钮
        self.textAdvanceBtn = self.view.textequipmentadvanced:GetComponent("TextMeshProUGUI")
        --self.textAdvanceBtn.fontSize = 40
        --UIUtil.SetTextAlignment(self.textAdvanceBtn,TextAnchor.MiddleCenter)
        --UIUtil.AddTextOutline(self.view.textequipmentadvanced,Color.New(255/255,222/255,191/255))
        self.view.textequipmentadvanced:GetComponent("RectTransform").sizeDelta = Vector2.New(90,45)
        self.textAdvanceBtn.text = uitext[1115005].NR
        self.imgAdvanceBtn = self.view.btnequipmentadvanced:GetComponent("Image")
        UIUtil.AddButtonEffect(self.view.btnequipmentadvanced,nil,nil)
        --进阶前
        --进阶等级
        self.textAdvanceBeforeLevel = self.view.lvStrengthenstonetitle1:GetComponent("TextMeshProUGUI")
        --属性1
        self.textAdvanceBeforeAttribute1 = self.view.textadvancedattribute1:GetComponent("TextMeshProUGUI")
        --属性2
        self.textAdvanceBeforeAttribute2 = self.view.textadvancedattribute3:GetComponent("TextMeshProUGUI")
        --属性3
        self.textAdvanceBeforeAttribute3 = self.view.textadvancedattribute5:GetComponent("TextMeshProUGUI")
        --进阶前装备图标
        self.imgAdvanceBeforeEquipIcon = self.view.iconStrengthenstonetitle1:GetComponent("Image")
        self.imgAdvanceBeforeEquipQuality = self.view.iconStrengthenstoneQuality1:GetComponent("Image")
        --进阶后
        --进阶等级
        self.textAdvanceOverLevel = self.view.lvStrengthenstonetitle2:GetComponent("TextMeshProUGUI")
        --属性1
        self.textAdvanceOverAttribute1 = self.view.textadvancedattribute2:GetComponent("TextMeshProUGUI")
        --属性2
        self.textAdvanceOverAttribute2 = self.view.textadvancedattribute4:GetComponent("TextMeshProUGUI")
        --属性3
        self.textAdvanceOverAttribute3 = self.view.textadvancedattribute6:GetComponent("TextMeshProUGUI")
        --进阶说明
        self.textAdvanceDescription = self.view.equipmentadvanceddescribe:GetComponent("TextMeshProUGUI")
        self.textAdvanceDescription.text = uitext[1115007].NR
        --进阶消耗
        --消耗数量1
        self.textAdvanceCostNumber1 = self.view.payiconnumerical1:GetComponent("TextMeshProUGUI")
        --进阶后装备图标
        self.imgAdvanceOverEquipIcon = self.view.iconStrengthenstonetitle2:GetComponent("Image")
        self.imgAdvanceOverEquipQuality = self.view.iconStrengthenstoneQuality2:GetComponent("Image")
        --消耗图标1
        self.imgAdvanceCostIcon1 = self.view.payicon1:GetComponent("Image")
        self.imgAdvanceCostQuality1 = self.view.payQuality1:GetComponent("Image")
        --消耗加号1
        --self.view.btnAdvancestoneadd1:SetActive(false)
        --消耗数量2
        self.textAdvanceCostNumber2 = self.view.payiconnumerical2:GetComponent("TextMeshProUGUI")
        --消耗图标2
        self.imgAdvanceCostIcon2 = self.view.payicon2:GetComponent("Image")
        self.imgAdvanceCostQuality2 = self.view.payQuality2:GetComponent("Image")
        --消耗加号2
        self.view.btnAdvancestoneadd2:SetActive(false)

        --默认成功失败隐藏
        self.view.effectStrengthen:SetActive(false)
        self.view.imgStrengthensuccess:SetActive(false)
        self.view.imgStrengthenfailure:SetActive(false)

        ClickEventListener.Get(self.view.btnclose).onClick = OnCloseBtnClick
        ClickEventListener.Get(self.view.btndetermine).onClick = OnStrengthenBtnClick
        ClickEventListener.Get(self.view.btnequipmentadvanced).onClick = OnAdvanceBtnClick
        -- ClickEventListener.Get(self.view.btnpaging1).onClick = OnUpgradeStartTabClick
        -- ClickEventListener.Get(self.view.btnsmelting).onClick = OnSmeltingTabClick
        -- ClickEventListener.Get(self.view.gemgem).onClick = OnGemTabClick
        ClickEventListener.Get(self.view.btnStrengthenstoneadd2).onClick = OnAddStrengthenItem1
        ClickEventListener.Get(self.view.StrengthenItemIcon2).onClick = OnAddStrengthenItem1
        ClickEventListener.Get(self.view.btnStrengthenstoneadd3).onClick = OnAddStrengthenItem2
        ClickEventListener.Get(self.view.StrengthenItemIcon3).onClick = OnAddStrengthenItem2
        ClickEventListener.Get(self.view.payicon1).onClick = OnAddStrengthenItem3
        ClickEventListener.Get(self.view.payicon2).onClick = OnAddStrengthenItem4
        --ClickEventListener.Get(self.view.btnrules).onClick = OnHelpBtnClick
        ClickEventListener.Get(self.view.StrengthenItemIcon1).onClick = OnStrengthenEquipmentClick
        ClickEventListener.Get(self.view.iconStrengthenstonetitle1).onClick = OnStrengthenEquipmentClick
        ClickEventListener.Get(self.view.iconStrengthenstonetitle2).onClick = OnStrengthenEquipmentClick
        ClickEventListener.Get(self.view.btnblessselect).onClick = OnSelectBlessItem
        ClickEventListener.Get(self.view.btnAdvancestoneadd1).onClick = OnAddStrengthenItem3

        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_STRENGTHEN_EQUIPMENT,OnEquipmentStrengthenReply)
        --self.view.transform.anchoredPosition3D = Vector3.New(self.view.transform.anchoredPosition3D.x,self.view.transform.anchoredPosition3D.y,-200)
    end

    self.UpdateView = function()
        if self.isReply then
            return
        end

        if BagManager.currentEquipSlot == "bag" then
            return
        end

        if BagManager.equipments[BagManager.currentEquipSlot] == nil then
            return
        end

        local itemconfig = itemconfigs[BagManager.equipments[BagManager.currentEquipSlot].id]
        if itemconfig == nil then
            return
        end

        local stage = 1
        local level = 0
        if BagManager.equipment_strengthen ~= nil and BagManager.equipment_strengthen[BagManager.currentEquipSlot] ~= nil then
            stage = BagManager.equipment_strengthen[BagManager.currentEquipSlot].stage
            level = BagManager.equipment_strengthen[BagManager.currentEquipSlot].level
        end
        --是否可以操作(强化或进阶)
        local canOprerate = true
        if level >= MAX_STRENGTHEN_LEVEL then
            --进阶
            self.view.Strengthenstoneui:SetActive(false)
            self.view.equipmentadvancedui:SetActive(true)
            self.imgAdvanceBeforeEquipIcon.overrideSprite = ResourceManager.LoadSprite("ItemIcon/"..itemconfig.Icon)
            self.imgAdvanceOverEquipIcon.overrideSprite = ResourceManager.LoadSprite("ItemIcon/"..itemconfig.Icon)
            self.imgAdvanceBeforeEquipQuality.overrideSprite = ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(itemconfig.Quality))
            self.imgAdvanceOverEquipQuality.overrideSprite = ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(itemconfig.Quality))
            --强化等级显示
            if stage == 1 then
                self.textAdvanceBeforeLevel.text = uitext[1114076].NR.."+"..level
                self.textAdvanceOverLevel.text = uitext[1114077].NR.."+0"
            elseif stage == 2 then
                self.textAdvanceBeforeLevel.text = uitext[1114077].NR.."+"..level
                self.textAdvanceOverLevel.text = uitext[1114078].NR.."+0"
            elseif stage == 3 then
                self.textAdvanceBeforeLevel.text = uitext[1114078].NR.."+"..level
                self.textAdvanceOverLevel.text = uitext[1114079].NR.."+0"
            elseif stage == 4 then
                self.textAdvanceBeforeLevel.text = uitext[1114079].NR.."+"..level
                self.textAdvanceOverLevel.text = uitext[1114080].NR.."+0"
            else
                self.textStrengthenBeforeLevel.text = uitext[1114080].NR.."+"..level
                self.textStrengthenOverLevel.text = uitext[1114080].NR.."+0"
            end
            --属性增强
            self.textAdvanceBeforeAttribute1.text = ""
            self.textAdvanceOverAttribute1.text = ""
            self.textAdvanceBeforeAttribute2.text = ""
            self.textAdvanceOverAttribute2.text = ""
            self.textAdvanceBeforeAttribute3.text = ""
            self.textAdvanceOverAttribute3.text = ""
            local count = 0
            local base_prop = {}
            for basename,basevalue in pairs(BagManager.equipments[BagManager.currentEquipSlot].base_prop) do
                if not AttributeConst.IsElementAttribute(basename) then
                    count = count + 1
                    table.insert(base_prop,{prop=basename,value=basevalue})
                end
            end

            if count > 1 then
                table.sort(base_prop,AttributeConst.BasePropSort)
            end
            for index=1,count,1 do
                local strengthen_value1 = 0
                local strengthen_value2 = 0
                if stage >= equipment_strengthen_config.get_max_strengthen_stage() then
                    strengthen_value1,strengthen_value2 = get_current_and_next_strengthen_addition(BagManager.currentEquipSlot,stage,stage,level,level,base_prop[index].prop,base_prop[index].value)
                else
                    strengthen_value1,strengthen_value2 = get_current_and_next_strengthen_addition(BagManager.currentEquipSlot,stage,stage+1,level,level,base_prop[index].prop,base_prop[index].value)
                end
                strengthen_value1 = math.floor(strengthen_value1)
                strengthen_value2 = math.floor(strengthen_value2)
                self["textAdvanceBeforeAttribute"..index].text = AttributeConst.GetAttributeNameByIndex(base_prop[index].prop).."  +"..(strengthen_value1)
                self["textAdvanceOverAttribute"..index].text = AttributeConst.GetAttributeNameByIndex(base_prop[index].prop).."  +"..(strengthen_value2)
            end

            --消耗显示
            local advance_cost_config = advance_cost_table[stage]
            if advance_cost_config then
                --消耗1
                local costItemConfig1 = itemconfigs[advance_cost_config.cost1[1]]
                if costItemConfig1 then
                    local costNumber1 = BagManager.GetItemNumberById(costItemConfig1.ID)
                    self.imgAdvanceCostIcon1.overrideSprite = ResourceManager.LoadSprite("ItemIcon/"..costItemConfig1.Icon)
                    self.imgAdvanceCostQuality1.overrideSprite = ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(costItemConfig1.Quality))
                    if not BagManager.IsResource(costItemConfig1.ID) then
                        if costNumber1 >= advance_cost_config.cost1[2] then
                            self.textAdvanceCostNumber1.text = string.format(uitext[1115019].NR,costNumber1,advance_cost_config.cost1[2])
                            self.view.btnAdvancestoneadd1:SetActive(false)
                        else
                            self.textAdvanceCostNumber1.text = string.format(uitext[1115020].NR,costNumber1,advance_cost_config.cost1[2])
                            canOprerate = false
                            self.view.btnAdvancestoneadd1:SetActive(false)
                        end
                    else
                        self.textAdvanceCostNumber1.text = advance_cost_config.cost1[2]
                        if costNumber1 >= advance_cost_config.cost1[2] then
                            self.textAdvanceCostNumber1.color = Color.New(251/255,238/255,227/255)
                        else
                            self.textAdvanceCostNumber1.color = Color.New(1,0,0)
                            canOprerate = false
                        end
                    end
                end

                --消耗2
                local costItemConfig2 = itemconfigs[advance_cost_config.cost2[1]]
                if costItemConfig2 then
                    local costNumber2 = BagManager.GetItemNumberById(costItemConfig2.ID)
                    self.imgAdvanceCostIcon2.overrideSprite = ResourceManager.LoadSprite("ItemIcon/"..costItemConfig2.Icon)
                    self.imgAdvanceCostQuality2.overrideSprite = ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(costItemConfig2.Quality))
                    if not BagManager.IsResource(costItemConfig2.ID) then
                        if costNumber2 >= advance_cost_config.cost2[2] then
                            self.textAdvanceCostNumber2.text = string.format(uitext[1115019].NR,costNumber2,advance_cost_config.cost2[2])
                        else
                            self.textAdvanceCostNumber2.text = string.format(uitext[1115020].NR,costNumber2,advance_cost_config.cost2[2])
                            canOprerate = false
                        end
                    else
                        self.textAdvanceCostNumber2.text = advance_cost_config.cost2[2]
                        if costNumber2 >= advance_cost_config.cost2[2] then
                            self.textAdvanceCostNumber2.color = Color.New(251/255,238/255,227/255)
                        else
                            self.textAdvanceCostNumber2.color = Color.New(1,0,0)
                            canOprerate = false
                        end
                    end
                end
            end
            if canOprerate then
                self.imgAdvanceBtn.material = nil
                self.textAdvanceBtn.material = nil
            else
                self.imgAdvanceBtn.material = UIGrayMaterial.GetUIGrayMaterial()
                self.textAdvanceBtn.material = UIGrayMaterial.GetUIGrayMaterial()
            end
        else
            self.view.Strengthenstoneui:SetActive(true)
            self.view.equipmentadvancedui:SetActive(false)
            self.imgStrengthenEquipIcon.overrideSprite = ResourceManager.LoadSprite("ItemIcon/"..itemconfig.Icon)
            self.imgStrengthenEquipQuality.overrideSprite = ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(itemconfig.Quality))

            --强化等级显示
            if stage == 1 then
                self.textStrengthenBeforeLevel.text = uitext[1114076].NR.."+"..level
                self.textStrengthenOverLevel.text = uitext[1114076].NR.."+"..(level+1)
            elseif stage == 2 then
                self.textStrengthenBeforeLevel.text = uitext[1114077].NR.."+"..level
                self.textStrengthenOverLevel.text = uitext[1114077].NR.."+"..(level+1)
            elseif stage == 3 then
                self.textStrengthenBeforeLevel.text = uitext[1114078].NR.."+"..level
                self.textStrengthenOverLevel.text = uitext[1114078].NR.."+"..(level+1)
            elseif stage == 4 then
                self.textStrengthenBeforeLevel.text = uitext[1114079].NR.."+"..level
                self.textStrengthenOverLevel.text = uitext[1114079].NR.."+"..(level+1)
            else
                self.textStrengthenBeforeLevel.text = uitext[1114080].NR.."+"..level
                self.textStrengthenOverLevel.text = uitext[1114080].NR.."+"..(level+1)
            end
            --属性增强
            self.textStrengthenBeforeAttribute1.text = ""
            self.textStrengthenOverAttribute1.text = ""
            self.textStrengthenBeforeAttribute2.text = ""
            self.textStrengthenOverAttribute2.text = ""
            self.textStrengthenBeforeAttribute3.text = ""
            self.textStrengthenOverAttribute3.text = ""
            local count = 0
            local base_prop = {}
            for basename,basevalue in pairs(BagManager.equipments[BagManager.currentEquipSlot].base_prop) do
                if not AttributeConst.IsElementAttribute(basename) then
                    count = count + 1
                    table.insert(base_prop,{prop=basename,value=basevalue})
                end
            end

            if count > 1 then
                table.sort(base_prop,AttributeConst.BasePropSort)
            end
            for index=1,count,1 do
                local strengthen_value1 = 0
                local strengthen_value2 = 0
                strengthen_value1,strengthen_value2 = get_current_and_next_strengthen_addition(BagManager.currentEquipSlot,stage,stage,level,level+1,base_prop[index].prop,base_prop[index].value)
                strengthen_value1 = math.floor(strengthen_value1)
                strengthen_value2 = math.floor(strengthen_value2)
                self["textStrengthenBeforeAttribute"..index].text = AttributeConst.GetAttributeNameByIndex(base_prop[index].prop).."  +"..(strengthen_value1)
                self["textStrengthenOverAttribute"..index].text = AttributeConst.GetAttributeNameByIndex(base_prop[index].prop).."  +"..(strengthen_value2)
            end

            --消耗显示
            local strengthen_cost_config = strengthen_cost_table[stage][level]
            if strengthen_cost_config then
                --成功率
                local ratio = strengthen_cost_config.score
                local silver_config = itemconfigs[strengthen_cost_config.silver[1]]
                if silver_config ~= nil then
                    if BagManager.GetItemNumberById(strengthen_cost_config.silver[1]) < strengthen_cost_config.silver[2] then
                        self.textSilverCost.text = string.format(uitext[1115008].NR,localization.GetItemName(strengthen_cost_config.silver[1]),"<color=#ff0000>",strengthen_cost_config.silver[2],"</color>")
                        canOprerate = false
                    else
                        self.textSilverCost.text = string.format(uitext[1115008].NR,localization.GetItemName(strengthen_cost_config.silver[1]),"<color=#00ff00>",strengthen_cost_config.silver[2],"</color>")
                    end
                end

                --强化石
                local curSelectStrengthenItemConfig = itemconfigs[curSelectStrengthenItemId]
                if curSelectStrengthenItemConfig then
                    ratio = ratio + tonumber(curSelectStrengthenItemConfig.Para2)
                    self.view.StrengthenItemQuality2:SetActive(true)
                    self.view.StrengthenItemIcon2:SetActive(true)
                    self.view.btnStrengthenstoneadd2:SetActive(false)
                    self.imgStrengthenIcon.overrideSprite = ResourceManager.LoadSprite("ItemIcon/"..curSelectStrengthenItemConfig.Icon)
                    self.imgStrengthenQuality.overrideSprite = ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(curSelectStrengthenItemConfig.Quality))
                    local strengthenNumber = BagManager.GetItemNumberById(curSelectStrengthenItemConfig.ID)
                    if strengthenNumber >= strengthen_cost_config.number then
                        self.textStrengthenNumber.text = string.format(uitext[1115019].NR,strengthenNumber,strengthen_cost_config.number)
                    else
                        self.textStrengthenNumber.text = string.format(uitext[1115020].NR,strengthenNumber,strengthen_cost_config.number)
                        canOprerate = false
                    end
                else
                    self.view.StrengthenItemQuality2:SetActive(false)
                    self.view.StrengthenItemIcon2:SetActive(false)
                    self.view.btnStrengthenstoneadd2:SetActive(true)
                    self.textStrengthenNumber.text = ""
                    canOprerate = false
                end

                --祝福石
                local blessconfig = itemconfigs[curSelectBlessItemId]
                if blessconfig then
                    local blessNumber = BagManager.GetItemNumberById(blessconfig.ID)
                    if blessNumber >= 1 then
                        if blessSelect then
                            ratio = ratio + tonumber(blessconfig.Para1)
                        end
                        self.textBlessNumber.text = string.format(uitext[1115019].NR,blessNumber,1)
                    else
                        self.textBlessNumber.text = string.format(uitext[1115020].NR,blessNumber,1)
                    end
                    self.view.StrengthenItemQuality3:SetActive(true)
                    self.view.StrengthenItemIcon3:SetActive(true)
                    self.imgBlessIcon.overrideSprite = ResourceManager.LoadSprite("ItemIcon/"..blessconfig.Icon)
                    self.view.btnStrengthenstoneadd3:SetActive(false)
                    self.imgBlessQuality.overrideSprite = ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(blessconfig.Quality))
                else
                    self.view.StrengthenItemQuality3:SetActive(false)
                    self.view.StrengthenItemIcon3:SetActive(false)
                    self.view.btnStrengthenstoneadd3:SetActive(true)
                    self.textBlessNumber.text = ""
                end
                if ratio < 20 then
                    self.textStrengthenSuccess.text = uitext[1115010].NR
                elseif ratio < 80 then
                    self.textStrengthenSuccess.text = uitext[1115011].NR
                else
                    self.textStrengthenSuccess.text = uitext[1115012].NR
                end
                if blessSelect then
                    self.view.bgblessselect:SetActive(true)
                else
                    self.view.bgblessselect:SetActive(false)
                end
            end
            if canOprerate then
                self.imgStrengthenBtn.material = nil
                self.textStrengthenBtn.material = nil
            else
                self.imgStrengthenBtn.material = UIGrayMaterial.GetUIGrayMaterial()
                self.textStrengthenBtn.material = UIGrayMaterial.GetUIGrayMaterial()
            end
        end
    end

    self.onUnload = function()
        self.isReply = false
        if strengthenResultTimer then
            Timer.Remove(strengthenResultTimer)
        end
        strengthenResultTimer = nil
    end

    return self
end

return CreateEquipmentStrengthenUICtrl()

