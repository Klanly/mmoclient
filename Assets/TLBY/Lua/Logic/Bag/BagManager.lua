--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/9/22 0022
-- Time: 18:53
-- To change this template use File | Settings | File Templates.
--

require "Common/basic/LuaObject"
require "Logic/Bag/ItemType"


local itemtable = require "Logic/Scheme/common_item"
local const = require "Common/constant"
local equipment_base = require "Logic/Scheme/equipment_base"
local uitext = require("Logic/Scheme/common_char_chinese").UIText
local localization = require "Common/basic/Localization"

local itemconfigs = itemtable.Item
local equip_type_to_name = const.equip_type_to_name
local PROPERTY_NAME_TO_INDEX = const.PROPERTY_NAME_TO_INDEX

local equipment_attribute_table = {}
for i,v in pairs(equipment_base.Attribute) do
    equipment_attribute_table[v.ID] = v
end

--玩家界面切页
RoleUITab = {BAG = 1,ATTRIBUTE = 2,INFO = 3 }
--装备锻造界面切页
EquipmentUITab = {STRENGTHEN = 1,UPGRADESTAR = 2,SMELTING = 3,GEM = 4}
--物品tips来源
ItemTipsFromType = {BAG = 1,PLAYER = 2 ,EQUIPMENT = 3,NORMAL = 4}
--强化最大等级
MAX_STRENGTHEN_LEVEL = MAX_STRENGTHEN_LEVEL or 9
--强化最大等阶
MAX_STRENGTHEN_STAGE = MAX_STRENGTHEN_STAGE or 5
--升星最大等级
MAX_STAR_LEVEL = MAX_STAR_LEVEL or 9

local resource_id_to_name = const.RESOURCE_ID_TO_NAME
local resource_name_to_id = const.RESOURCE_NAME_TO_ID

local function CreateBagManager()
    local self = CreateObject()

    local updateEvent = CreateEvent() -- 包裹更新事件
    local eventKey = 'OnBagUpdate'
    self.AddBagListener = function(func)
        updateEvent.AddListener(eventKey, func)
    end
    self.RemoveBagListener = function(func)
        updateEvent.RemoveListener(eventKey, func)
    end

    self.sellItems = {}
    self.sellFlag = false
    self.selectPos = 0

    local init_resource = function()
        local resource = {}
        for _,v in pairs(resource_id_to_name) do
            resource[v] = 0
        end
        return resource
    end
    --资源
    self.resource = self.resource or init_resource()
    --背包道具
    self.items = self.items or {}
    --max_unlock_cell
    self.max_unlock_cell = self.max_unlock_cell or 40
    --装备属性约定
    --additional_prop = {6,112,false,2} 6--属性编号112属性值false是否珍品2值类别(1万分比2数值)
    --base_prop={[1]=131, [9]=1096}属性编号=属性值
    self.equipments = self.equipments or {}
    --装备强化
    self.equipment_strengthen = self.equipment_strengthen or {}
    --装备升星
    self.equipment_star = self.equipment_star or {}
    --装备宝石
    self.equipment_gem = self.equipment_gem or {}
    --装备界面选中槽位
    self.currentEquipSlot = "Weapon"
    --洗练时选中的索引
    self.currentSmeltingPos = 0
    --装备界面当前切页
    self.currentEquipTab = EquipmentUITab.STRENGTHEN
    --洗练预先选中装备在背包位置
    self.currentEquipmentPos = 0

    --属性信息
    self.property = self.property or {}
    --换装的时候会设置为真
    self.dressing = false
    self.propertyDelay = 0
    self.propertyDelayTimer = nil
    --背包被锁定,使用部分道具时会锁定
    self.lock = false
    --绑定铜钱转换提示
    self.isBindCoin = true
    --药物cd
    self.drug_cds = self.drug_cds or {}
    --战斗力
    self.fight_power = nil
    --综合实力
    self.total_power = nil

    self.RemovePropertyDelayTimer = function()
        if self.propertyDelayTimer ~= nil then
            Timer.Remove(self.propertyDelayTimer)
            self.propertyDelayTimer = nil
        end
    end

    self.OnUpdateBag = function(data)
        local _data = nil
        if data.login_data ~= nil then
            if data.login_data.items == nil then
                return
            end
            _data = data.login_data
        else
            if data.items == nil then
			    return
            end
            _data = data
        end

        if self.resource["bind_coin"] <= 0 and _data.bind_coin > 0 then
            self.isBindCoin = true
        end

        self.items = _data.items or self.items
        self.max_unlock_cell = _data.max_unlock_cell or self.max_unlock_cell
        self.drug_cds = _data.drug_cds or self.drug_cds
        for _,v in pairs(resource_id_to_name) do
            self.resource[v] = _data[v] or self.resource[v]
        end

        --刷新是否提示属性变化
        if self.dressing and _data.property ~= nil then
            local changes = {}
            local count = 0
            changes[count] = {property=0,number1=self.fight_power,number2=_data.fight_power or self.fight_power }
            count = count + 1
            changes[count] = {property=-1,number1=self.total_power,number2=_data.total_power or self.total_power }
            for i,_ in pairs(self.property) do
                if i ~= PROPERTY_NAME_TO_INDEX.move_speed then
                    if _data.property[i] == nil then
                        if self.property[i] > 0 then
                            count = count + 1
                            changes[count] = {property=i,number1=self.property[i],number2=0 }
                        end
                    elseif _data.property[i] ~= self.property[i] then
                        count = count + 1
                        changes[count] = {property=i,number1=self.property[i],number2=_data.property[i] }
                    end
                end
            end
            for i,_ in pairs(_data.property) do
                if i ~= PROPERTY_NAME_TO_INDEX.move_speed then
                    if self.property[i] == nil then
                        if _data.property[i] > 0 then
                            count = count + 1
                            changes[count] = {property=i,number1=0,number2=_data.property[i] }
                        end
                    end
                end
            end
            if count > 1 then
                self.RemovePropertyDelayTimer()
                Timer.Delay(self.propertyDelay,function()
                    self.RemovePropertyDelayTimer()
                    if not UIManager.GetCtrl(ViewAssets.PropertyChangeUI).isLoaded then
                        UIManager.PushView(ViewAssets.PropertyChangeUI,nil,changes)
                    else
                        UIManager.GetCtrl(ViewAssets.PropertyChangeUI).UpdateData(changes)
                    end
                end)
                self.propertyDelay = 0
            end
        end
        self.property = _data.property or self.property
        if _data.fight_power ~= nil then
            self.fight_power = _data.fight_power
        end
        if _data.total_power ~= nil then
            self.total_power = _data.total_power
        end

        if UIManager.GetCtrl(ViewAssets.BagUI).isLoaded then
            UIManager.GetCtrl(ViewAssets.BagUI).UpdateBagItems()
        end
        if UIManager.GetCtrl(ViewAssets.GiftGivingUI).isLoaded then
            UIManager.GetCtrl(ViewAssets.GiftGivingUI).UpdateData()
        end
        
        if UIManager.GetCtrl(ViewAssets.PurchaseUI).isLoaded then
            UIManager.GetCtrl(ViewAssets.PurchaseUI).UpdateView()
        end
        
        UIManager.GetCtrl(ViewAssets.PlayerResourceUI).UpdateData()
        UIManager.GetCtrl(ViewAssets.PetUpgradeUI).RefreshUI()
        UIManager.GetCtrl(ViewAssets.CampItemSubmitUI).UpdateData()
        self.dressing = false
        UIManager.GetCtrl(ViewAssets.EquipGemUI).RefreshGemList()
        UIManager.GetCtrl(ViewAssets.EquipGemHandleUI).Reload()

        updateEvent.Brocast(eventKey, 'bag')
    end

    local OnUpdateEquipments = function(data)
        if data.login_data ~= nil then
            if data.login_data.equipments == nil then
                return
            end
        elseif data.equipments == nil then
			return
        end

        if data.equipments then
            self.equipments = data.equipments or self.equipments
            self.equipment_strengthen = data.equipment_strengthen or self.equipment_strengthen
            self.equipment_star = data.equipment_star or self.equipment_star
        else
            self.equipments = data.login_data.equipments or self.equipments
            self.equipment_strengthen = data.login_data.equipment_strengthen or self.equipment_strengthen
            self.equipment_star = data.login_data.equipment_star or self.equipment_star
        end

        if UIManager.GetCtrl(ViewAssets.RoleUI).isLoaded then
            UIManager.GetCtrl(ViewAssets.RoleUI).UpdateEqupments()
        end
        if UIManager.GetCtrl(ViewAssets.EquipmentUI).isLoaded then
            UIManager.GetCtrl(ViewAssets.EquipmentUI).UpdateView()
        end
        updateEvent.Brocast(eventKey, 'equip')
    end

    local function OnGetBagItemsReply (data)
		if data.result == 0 then
			return
		else
			UIManager.ShowErrorMessage(data.result)
		end
    end

    local function OnUseBagItemReply (data)
		if data.result == 0 then
			return
		else
			UIManager.ShowErrorMessage(data.result)
		end
	end

	local function OnUseEquipmentReply (data)
	end

	local function OnSplitBagItemsReply (data)
		print("OnSplitBagItemsReply,result:"..data.result)
	end

	local function OnSellBagItemsReply (data)
		print("OnSellBagItemsReply,result:"..data.result)
    end

    local function OnUnlockReply(data)
        print("OnUnlockReply,result=="..data.result)
    end

    --获得奖励
    local function OnRequireItem(data)
        if self.reward_items == nil then
            self.reward_items = {}
        end

        for itemid,itemcount in pairs(data) do
            table.insert(self.reward_items,{itemid=itemid,itemcount=itemcount})
        end
        if self.rewards_notice_timer == nil then
            self.rewards_notice_timer = Timer.Repeat(0.1,function()
                if #self.reward_items > 0 then
                    local item_config = itemconfigs[self.reward_items[1].itemid]
                    if item_config ~= nil then
                        UIManager.ShowTopNotice(string.format(uitext[1101074].NR,string.format("<color=%s>%s<color=#F6F0DE>",QualityConst.GetQualityColor2String(item_config.Quality),localization.GetItemName(self.reward_items[1].itemid)),self.reward_items[1].itemcount))
                    end
                    table.remove(self.reward_items,1)
                else
                    if self.rewards_notice_timer ~= nil then
                        Timer.Remove(self.rewards_notice_timer)
                        self.rewards_notice_timer = nil
                    end
                end
            end)
        end
    end

    self.Init = function()
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_LOGIN, self.OnUpdateBag)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_UPDATE, self.OnUpdateBag)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_LOGIN, OnUpdateEquipments)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_UPDATE, OnUpdateEquipments)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_BAG_GET_ALL, OnGetBagItemsReply)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ITEM_USE, OnUseBagItemReply)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ITEM_SPLIT, OnSplitBagItemsReply)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ITEM_SELL, OnSellBagItemsReply)
		MessageManager.RegisterMessage(MSG.CS_MESSAGE_LUA_UNLOCK_CELL,OnUnlockReply)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_REQUIRE,OnRequireItem)
        -- MessageRPCManager.AddUser(self, 'GetExpFromMonster')
        -- MessageRPCManager.AddUser(self, 'KillPlayerRet')
        -- MessageRPCManager.AddUser(self, 'BeKilledRet')
        MessageRPCManager.AddUser(self, 'UseBagItemReply')
        MessageRPCManager.AddUser(self,'GetRewardsNotice')
    end
    
    -- self.GetExpFromMonster = function(data)
        -- UIManager.ShowTopNotice('获得经验'..data.exp)
    -- end

    self.UseBagItemReply = function(data)
        if data.result == 0 then
            if data.seal_energy ~= nil then
                UIManager.ShowNotice(string.format(uitext[1101044].NR,data.seal_energy))
            elseif data.pet_id ~= nil then
                UIManager.ShowNotice(string.format(uitext[1101045].NR,LuaUIUtil.GetPetName(data.pet_id)))
            elseif data.reduce_pk_value ~= nil then
                UIManager.ShowNotice(string.format(uitext[1101046].NR,data.reduce_pk_value))
            elseif data.items ~= nil then
                OnRequireItem(data.items)
            elseif data.random_transport ~= nil then
                SceneManager.GetEntityManager().hero:SetPosition(Vector3.New(data.posX/100,data.posY/100,data.posZ/100))
                CameraManager.CameraController:Reset()
            elseif data.locate_position ~= nil then
                local scene_config = GetConfig("common_scene").MainScene[data.scene_id]
                if scene_config ~= nil then
                    UIManager.ShowNotice(string.format(uitext[1101055].NR,LuaUIUtil.GetTextByID(GetConfig("common_scene").MainScene[data.scene_id],'Name'),data.posX/100,data.posZ/100))
                end
            elseif data.play_effect ~= nil then
                local entity_id = SceneManager.GetEntityManager().GenerateEntityUID()
                local go = SceneManager.GetEntityManager().CreateEmptyGO({
                    entity_id=entity_id,
                    posX=data.posX/100,
                    posY=data.posY/100,
                    posZ=data.posZ/100,
                })
                go:AddEffect(data.effect_path,nil,data.duration)
                Timer.Numberal(data.duration,1,function()
                    SceneManager.GetEntityManager().DestroyPuppet(entity_id)
                end)
            elseif data.change_player_name ~= nil then
                UIManager.UnloadView(ViewAssets.ModifyNameUI)
                local roleCtrl = UIManager.GetCtrl(ViewAssets.RoleUI)
                if roleCtrl and roleCtrl.isLoaded and data.new_name ~= nil then
                    MyHeroManager.heroData.actor_name = data.new_name
                    roleCtrl.UpdateView()
                end
            elseif data.gift_giving ~= nil then
                UIManager.ShowNotice(uitext[1101066].NR)
            end
        else
            UIManager.ShowErrorMessage(data.result)
        end
    end

    self.GetFirstPosOfEquipByType = function(type)
        for k,v in pairs(self.items) do
            if v then
                local vconfig = itemtable.Item[v.id]
                if vconfig and vconfig.Type == type then
                    return k
                end
            end
        end
        return 0
    end

    self.GetRewardsNotice = function(data)
        if SceneManager.isSceneLoading == false then
            UIManager.PushView(ViewAssets.ObtainUI,function(ctrl)
                ctrl.UpdateData(data.rewards)
            end)
        end
    end

    self.ShowCanUseEquip = function(type)
        local pos = self.GetFirstPosOfEquipByType(type)
        if pos <= 0 then
            return
        end

        self.selectPos = pos
        
        UIManager.UnloadView(ViewAssets.RoleUI)
        if not UIManager.GetCtrl(ViewAssets.BagUI).isLoaded then
            UIManager.PushView(ViewAssets.BagUI,function(ctrl) 
                UIManager.ShowItemTips({from=ItemTipsFromType.BAG,pos=pos,item_data=BagManager.items[pos]})
                ctrl.UpdateBagItems()
                ctrl.SetContentPosition(pos)
            end)
        else     
            UIManager.ShowItemTips({from=ItemTipsFromType.BAG,pos=pos,item_data=BagManager.items[pos]})   
            UIManager.GetCtrl(ViewAssets.BagUI).UpdateBagItems()
            UIManager.GetCtrl(ViewAssets.BagUI).SetContentPosition(pos)
        end

    end

    self.GetItemNumberById = function(id)
        if resource_id_to_name[id] ~= nil then
            return self.GetResourceNumberByid(id)
        end

        local count = 0
        for i,v in pairs(self.items) do
            if v.id == id then
                count = count + v.count
            end
        end
        return count
    end

    self.IsResource = function(id)
        if resource_id_to_name[id] ~= nil then
            return true
        end
        return false
    end

    self.GetResourceNumberByid = function(id)
        if resource_id_to_name[id] == nil then
            return 0
        end
--        if id == resource_name_to_id.bind_coin then
--            return self.resource[resource_id_to_name[id]] + self.GetResourceNumberByid(resource_name_to_id.coin)
--        end
        return self.resource[resource_id_to_name[id]]
    end

    self.GetItemNumberByType = function(type)
        local count = 0
        for i,v in pairs(itemconfigs) do
            if v.Type == type then
                count = count + self.GetItemNumberById(v.ID)
            end
        end
        return count
    end

    self.GetItemConfigByType = function(type)
        for i,v in pairs(itemconfigs) do
            if v.Type == type then
                return v
            end
        end
        return nil
    end
	
	 self.GetItemIdsBySelector = function(Selector,sortFuc)
        local ids = {}
        for i,v in pairs(itemconfigs) do
            if Selector(v) then
                table.insert(ids,v.ID)
            end
        end
		if sortFuc ~= nil then
          table.sort(ids,sortFuc)
		end
        return ids
    end

    self.GetItemIdsByType = function(type)
        local ids = {}
        for i,v in pairs(itemconfigs) do
            if v.Type == type then
                table.insert(ids,v.ID)
            end
        end
        table.sort(ids,function(a,b)
                if a < b then
                    return true
                else
                    return false
                end
            end)
        return ids
    end

    self.GetEquipmentsPosByType = function(type)
        local poss = {}
        for k,v in pairs(self.items) do
            if v then
                local vconfig = itemtable.Item[v.id]
                if vconfig and vconfig.Type == type then
                    table.insert(poss,k)
                end
            end
        end
        return poss
    end

    --获得可洗练装备位置列表
    self.GetSmeltingEquipmentsPosByType = function(type)
        local poss = {}
        for k,v in pairs(self.items) do
            if self.IsSmeltingEquipmentByTypeAndPosition(type,k) then
                table.insert(poss,k)
            end
        end

        table.sort(poss,function(a,b)
            local cfg_a = itemconfigs[self.items[a].id]
            local cfg_b = itemconfigs[self.items[b].id]
            if cfg_a.Quality > cfg_b.Quality then
                return true
            elseif cfg_b.Quality > cfg_a.Quality then
                return false
            elseif cfg_a.LevelLimit > cfg_b.LevelLimit then
                return true
            elseif cfg_b.LevelLimit > cfg_a.LevelLimit then
                return false
            end
        end)

        return poss
    end

    --通过位置和类型判断是否可洗练
    self.IsSmeltingEquipmentByTypeAndPosition = function(type,pos)
        if self.equipments[equip_type_to_name[type]] == nil or self.equipments[equip_type_to_name[type]].additional_prop == nil then
            return false
        end
        if self.items[pos] == nil or self.items[pos].additional_prop == nil then
            return false
        end
        local itemcfg1 = itemconfigs[self.equipments[equip_type_to_name[type]].id]
        local itemcfg2 = itemconfigs[self.items[pos].id]
        if itemcfg1 == nil or itemcfg2 == nil or itemcfg1.Type ~=  itemcfg2.Type then
            return false
        end

        local result = false
        for i,v in pairs(self.items[pos].additional_prop) do
            local tmp = false
            for j,p in pairs(self.equipments[equip_type_to_name[type]].additional_prop) do
                --如果一样属性且比较好
                if p[5] == v[5] and p[2] >= v[2] then
                    tmp = true
                    break
                end
            end

            --没有比较好的属性
            if not tmp then
                result = true
                break
            end
        end
        return result
    end

    --获得可洗练装备位置列表
    self.GetSmeltingEquipmentsPosByPos = function(pos)
        local poss = {}
        for k,v in pairs(self.items) do
            if k ~= pos and self.IsSmeltingEquipmentByPosition(pos,k) then
                table.insert(poss,k)
            end
        end

        table.sort(poss,function(a,b)
            local cfg_a = itemconfigs[self.items[a].id]
            local cfg_b = itemconfigs[self.items[b].id]
            if cfg_a.Quality > cfg_b.Quality then
                return true
            elseif cfg_b.Quality > cfg_a.Quality then
                return false
            elseif cfg_a.LevelLimit > cfg_b.LevelLimit then
                return true
            elseif cfg_b.LevelLimit > cfg_a.LevelLimit then
                return false
            end
        end)

        return poss
    end

    --通过位置判断是否可洗练
    self.IsSmeltingEquipmentByPosition = function(pos1,pos2)
        if self.items[pos1] == nil or self.items[pos1].additional_prop == nil then
            return false
        end
        if self.items[pos2] == nil or self.items[pos2].additional_prop == nil then
            return false
        end
        local itemcfg1 = itemconfigs[self.items[pos1].id]
        local itemcfg2 = itemconfigs[self.items[pos2].id]
        if itemcfg1 == nil or itemcfg2 == nil or itemcfg1.Type ~=  itemcfg2.Type then
            return false
        end

        local result = false
        for i,v in pairs(self.items[pos2].additional_prop) do
            local tmp = false
            for j,p in pairs(self.items[pos1].additional_prop) do
                --如果一样属性且比较好
                if p[5] == v[5] and p[2] >= v[2] then
                    tmp = true
                    break
                end
            end

            --没有比较好的属性
            if not tmp then
                result = true
                break
            end
        end
        return result
    end

    self.GetEquipmets = function()
        local poss = {}
        for k,v in pairs(self.items) do
            local itemconfig = itemconfigs[v.id]
            if ItemType.IsEquipByType(itemconfig.Type) then
                table.insert(poss,k)
            end
        end
        table.sort(poss,function(a,b)
            local cfg_a = itemconfigs[self.items[a].id]
            local cfg_b = itemconfigs[self.items[b].id]
            if cfg_a.Quality > cfg_b.Quality then
                return true
            elseif cfg_b.Quality > cfg_a.Quality then
                return false
            elseif cfg_a.LevelLimit > cfg_b.LevelLimit then
                return true
            elseif cfg_b.LevelLimit > cfg_a.LevelLimit then
                return false
            end
        end)

        return poss
    end

    self.IsBagFull = function()
        for i = 1,self.max_unlock_cell,1 do
            if self.items[i] == nil then
                return false
            end
        end
        return true
    end

    self.GetCoin = function()
        return self.resource["coin"]
    end

    self.GetBindCoin = function()
        return self.resource["bind_coin"]
    end

    self.GetTotalCoin = function()
        return self.resource["bind_coin"] + self.resource["coin"]
    end

    self.GetIngot = function()
        return self.resource["ingot"]
    end

    self.GetTili = function()
        return self.resource["tili"]
    end

    self.GetExp = function()
        return self.resource["exp"]
    end

    self.GetPvpScore = function()
        return self.resource["pvp_score"]
    end

    self.GetSilver = function()
        return self.resource["silver"]
    end

    self.GetDungeonScore = function()
        return self.resource["dungeon_score"]
    end

    self.GetTalentCoin = function()
        return self.resource["talent_coin"]
    end

    self.GetTalentExp = function()
        return self.resource["talent_exp"]
    end

    self.GetBindCoinNotEnoughString = function(need)
        local count = need - self.GetBindCoin()
        if count < 0 then
            count = 0
        end
        return string.format(uitext[1101069].NR,localization.GetItemName(resource_name_to_id.bind_coin),count,localization.GetItemName(resource_name_to_id.coin))
    end

    self.CheckItemIsEnough = function(items,hideNotice)
        local item_id = 0
        for _,v in pairs(items) do
            if v[1] == resource_name_to_id.bind_coin then
                if v[2] > self.GetTotalCoin() then
                    item_id = resource_name_to_id.bind_coin
                    break
                end
            elseif v[2] > self.GetItemNumberById(v[1]) then
                item_id = v[1]
                break
            end
        end
        if item_id == 0 then
            return true
        end
        if not hideNotice then
            UIManager.ShowNotice(uitext[1101070].NR)
        end
        return false
    end

    self.CheckItemIsEnoughEx = function(items,hideNotice)
        local item_id = 0
        for itemid,item_count in pairs(items) do
            if itemid == resource_name_to_id.bind_coin then
                if item_count > self.GetTotalCoin() then
                    item_id = resource_name_to_id.bind_coin
                    break
                end
            elseif item_count > self.GetItemNumberById(itemid) then
                item_id = itemid
                break
            end
        end
        if item_id == 0 then
            return true
        end
        if not hideNotice then
            UIManager.ShowNotice(uitext[1101070].NR)
        end
        return false
    end

    local CheckBindCoinIsEnoughCancelHandle = function()
        self.isBindCoin = true
    end

    self.CheckBindCoinIsEnough = function(items,func)
        for _,v in pairs(items) do
            if v[1] == resource_name_to_id.bind_coin then
                if v[2] <= self.GetBindCoin() then
                    self.isBindCoin = true
                else
                    if v[2] <= self.GetTotalCoin() then
                        if self.isBindCoin == true then
                            self.isBindCoin = false
                            UIManager.ShowDialog(self.GetBindCoinNotEnoughString(v[2]),uitext[1101006].NR,uitext[1101007].NR,func,CheckBindCoinIsEnoughCancelHandle)
                            return
                        end
                    else
                        return
                    end
                end
                break
            end
        end
        func()
    end

    self.CheckBindCoinIsEnoughEx = function(items,func)
        for item_id,value in pairs(items) do
            if item_id == resource_name_to_id.bind_coin then
                if value <= self.GetBindCoin() then
                    self.isBindCoin = true
                else
                    if value <= self.GetTotalCoin() then
                        if self.isBindCoin == true then
                            self.isBindCoin = false
                            UIManager.ShowDialog(self.GetBindCoinNotEnoughString(value),uitext[1101006].NR,uitext[1101007].NR,func,CheckBindCoinIsEnoughCancelHandle)
                            return
                        end
                    else
                        return
                    end
                end
                break
            end
        end
        func()
    end

    self.CheckDrugCD = function(type)
        if self.drug_cds[type] == nil then
            return true
        end
        local cd = networkMgr:GetConnection():GetTimespanSeconds(self.drug_cds[type])
        if cd <= 0 then
            return true
        end
        return false
    end

    self.GetItemFirstPos = function(id)
        for i,item in pairs(self.items) do
            if id == item.id then
                return i
            end
        end
        return 0
    end

    --获得当前拥有恢复药剂物品列表
    self.GetRecoveryDrugIds = function(type,selector)
        local ids = {}
        local _ids = {}
		local retFuc = function(data)
			if selector then 
			   return selector(data) 
			else 
			   return true  
			end
		end
        for _,item in pairs(self.items) do
            local item_config = itemconfigs[item.id]
            if item_config.Type == const.TYPE_RECOVERY_DRUG and math.floor(tonumber(item_config.Para1)) == type and retFuc(item_config) then
                if _ids[item.id] == nil then
                    _ids[item.id] = true
                    table.insert(ids,item.id)
                end
            end
        end
        return ids
    end

    --人物血药
    self.GetBloodDrugIds = function()
        return self.GetRecoveryDrugIds(const.RECOVERY_DRUG_TYPE.actor_hp)
    end

    --人物法药
    self.GetMagicDrugIds = function()
        return self.GetRecoveryDrugIds(const.RECOVERY_DRUG_TYPE.actor_mp)
    end

    --宠物血药
    self.GetPetBloodDrugIds = function()
        return self.GetRecoveryDrugIds(const.RECOVERY_DRUG_TYPE.pet_hp)
    end
	
	self.GetTopLevelDrugId = function(Type) --得到能使用的最高等级药
		 local Drugid = -1
		 local durgIds = self.GetRecoveryDrugIds(Type,function(item)
		    if item.LevelLimit <= MyHeroManager.heroData.level and self.CheckDrugCD(math.floor(tonumber(item.Para1))) then 
		       return true 
			else return false
			end
		 end)
		if next(durgIds) ~=nil then
			table.sort(durgIds,function(a,b) return  itemconfigs[a].LevelLimit > itemconfigs[b].LevelLimit end)
			Drugid = durgIds[1]
		end
		return Drugid
	end

    self.UseRecoveryDrug = function(id)
        local item_config = itemconfigs[id]
        if item_config == nil then
            return
        end
        if item_config.Type ~= const.TYPE_RECOVERY_DRUG then
            return
        end
		
        if self.CheckDrugCD(math.floor(tonumber(item_config.Para1))) == false then
            return
        end
        
		if MyHeroManager.heroData.level < item_config.LevelLimit then
			return
        end
        local pos = self.GetItemFirstPos(id)
        if pos == 0 then  --自动切换时自动服用等级最高的药
		   if GlobalManager.AutoSwitchDurg == false then return end
           if math.floor(tonumber(item_config.Para1)) == const.RECOVERY_DRUG_TYPE.actor_hp then
	          id = self.GetTopLevelDrugId(const.RECOVERY_DRUG_TYPE.actor_hp)
		   elseif math.floor(tonumber(item_config.Para1)) == const.RECOVERY_DRUG_TYPE.actor_mp then
	          id = self.GetTopLevelDrugId(const.RECOVERY_DRUG_TYPE.actor_mp)
		   elseif math.floor(tonumber(item_config.Para1)) == const.RECOVERY_DRUG_TYPE.pet_hp then
	          id = self.GetTopLevelDrugId(const.RECOVERY_DRUG_TYPE.pet_hp)
		   end
		   if id~= -1 then pos = self.GetItemFirstPos(id) end
        end
		if pos ~= 0 then 
           MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GAME_RPC, {func_name="on_use_recovery_drug",item_pos=pos,count=1})
		end
    end

    --data.from 来源,在BagManager中定义
    --data.pos 背包中的位置 或 玩家身上装备名称
    --data.item_data 物品数据
    self.ShowItemTips = function(data,mask)
        if data.item_data == nil or data.item_data.id == nil then
            return
        end
        if data.from == nil then
            data.from = ItemTipsFromType.NORMAL
        end
        if data.from == ItemTipsFromType.BAG and data.pos == nil then
            return
        end
        local item_config = itemconfigs[data.item_data.id]
        if item_config == nil then
            return
        end
        if data.item_data.base_prop == nil or not ItemType.IsEquipById(data.item_data.id) then
            --普通物品或未产生的装备
            local function _ShowItemTips()
                UIManager.GetCtrl(ViewAssets.ItemTipsUI).UpdatePosition(0,-20)
                UIManager.GetCtrl(ViewAssets.ItemTipsUI).UpdateData(data)
                if mask ~= nil then
                    UIManager.GetCtrl(ViewAssets.ItemTipsUI).SetBgMaskActive(mask)
                end
            end
            UIManager.UnloadView(ViewAssets.EquipTipsUI)
            UIManager.UnloadView(ViewAssets.CompareEquipTipsUI)
            if not UIManager.GetCtrl(ViewAssets.ItemTipsUI).isLoaded then
                UIManager.PushView(ViewAssets.ItemTipsUI,_ShowItemTips)
            else
                _ShowItemTips()
            end

        else
            --已产生装备
            UIManager.UnloadView(ViewAssets.ItemTipsUI)
            if data.from == ItemTipsFromType.BAG and BagManager.equipments[equip_type_to_name[item_config.Type]] ~= nil and not BagManager.sellFlag then
                local function _ShowEquipTips()
                    UIManager.GetCtrl(ViewAssets.EquipTipsUI).UpdateData(data)
                    UIManager.GetCtrl(ViewAssets.EquipTipsUI).UpdatePosition(110,-20)
                    UIManager.GetCtrl(ViewAssets.EquipTipsUI).SetBgMaskActive(false)
                end
                --来自背包，将进行比较
                if not UIManager.GetCtrl(ViewAssets.EquipTipsUI).isLoaded then
                    UIManager.PushView(ViewAssets.EquipTipsUI,_ShowEquipTips)
                else
                    _ShowEquipTips()
                end

                local function _ShowCompareEquipTips()
                    UIManager.GetCtrl(ViewAssets.CompareEquipTipsUI).UpdateData({from=ItemTipsFromType.PLAYER,pos=equip_type_to_name[item_config.Type],item_data=BagManager.equipments[equip_type_to_name[item_config.Type]]})
                    UIManager.GetCtrl(ViewAssets.CompareEquipTipsUI).UpdatePosition(-510,-20)
                    UIManager.GetCtrl(ViewAssets.CompareEquipTipsUI).SetBgMaskActive(false)
                end
                if not UIManager.GetCtrl(ViewAssets.CompareEquipTipsUI).isLoaded then
                    UIManager.PushView(ViewAssets.CompareEquipTipsUI,_ShowCompareEquipTips)
                else
                    _ShowCompareEquipTips()
                end

            else
                local function _ShowEquipTips()
                    UIManager.GetCtrl(ViewAssets.EquipTipsUI).UpdateData(data)
                    UIManager.GetCtrl(ViewAssets.EquipTipsUI).UpdatePosition(0,-20)
                    if mask ~= nil then
                        UIManager.GetCtrl(ViewAssets.EquipTipsUI).SetBgMaskActive(mask)
                    end
                end
                if not UIManager.GetCtrl(ViewAssets.EquipTipsUI).isLoaded then
                    UIManager.PushView(ViewAssets.EquipTipsUI,_ShowEquipTips)
                else
                    _ShowEquipTips()
                end

                UIManager.UnloadView(ViewAssets.CompareEquipTipsUI)
            end
        end
    end

    self.CloseItemTips = function()
        UIManager.UnloadView(ViewAssets.ItemTipsUI)
        UIManager.UnloadView(ViewAssets.EquipTipsUI)
        UIManager.UnloadView(ViewAssets.CompareEquipTipsUI)
    end

    self.CloseRoleUI = function()
        BagManager.CloseItemTips()
        UIManager.UnloadView(ViewAssets.RoleappearanceUI)
        UIManager.UnloadView(ViewAssets.BagUI)
        UIManager.UnloadView(ViewAssets.RoleAttributeUI)
        UIManager.UnloadView(ViewAssets.RoleUI)
    end

    self.Init()

    return self
end

BagManager = BagManager or CreateBagManager()

