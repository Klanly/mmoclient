--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/9/29 0029
-- Time: 14:57
-- To change this template use File | Settings | File Templates.
--

require "UI/Controller/LuaCtrlBase"
require "Logic/Bag/ItemType"
require "Logic/Bag/QualityConst"

local itemtable = require "Logic/Scheme/common_item"
local texttable = require "Logic/Scheme/common_char_chinese"
local localization = require "Common/basic/Localization"
local const = require "Common/constant"
local gemTable = require "Logic/Scheme/equipment_jewel"
local math = require "math"

local function CreateItemTipsUICtrl()
    local self = CreateCtrlBase()
    local itemdata = nil
    self.layer = LayerGroup.popCanvas
    local UseItemHandle = function(pos,count)
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ITEM_USE, {item_pos=pos,count=count})
    end

    local UseStealthyItem = function()
        if SceneManager.GetEntityManager().hero:CheckOperationStatus(const.HERO_OPERATION_STATUS.None) == true then
            SceneManager.GetEntityManager().hero:UseStealthyCharacter(itemdata.pos,itemdata.item_data.id)
            UIManager.UnloadView(ViewAssets.RoleUI)
            UIManager.UnloadView(ViewAssets.BagUI)
            BagManager.lock = true
        else
            SceneManager.GetEntityManager().hero:ShowOperationStatus()
        end
    end

    --使用物品（非装备）
    local OnUseBtnClick = function()
        if BagManager.lock == true then
            UIManager.ShowNotice(texttable.UIText[1101056].NR)
            return
        end
        if not itemdata.item_data.id or ItemType.IsEquipById(itemdata.item_data.id) then
            return
        end

        if itemtable.Item[itemdata.item_data.id].Type == const.TYPE_GEM then
            UIManager.PushView(ViewAssets.EquipGemHandleUI,nil,1)
            UIManager.UnloadView(ViewAssets.ItemTipsUI)
            return
        end
        local item_config = itemtable.Item[itemdata.item_data.id]
        if item_config ~= nil then
            if MyHeroManager.heroData.level < item_config.LevelLimit then
                UIManager.ShowErrorMessage(const.error_level_not_enough)
                return
            end
            if item_config.Type == const.TYPE_ADD_BUFF then
                local buff_id = tonumber(item_config.Para1)
                local skillManager = SceneManager.GetEntityManager().hero.skillManager
                if skillManager ~= nil then
                    local buff = skillManager:FindBuff(buff_id)
                    if buff ~= nil then
                        UIManager.ShowDialog(texttable.UIText[1101042].NR,texttable.UIText[1101006].NR,texttable.UIText[1101007].NR,function()
                            UseItemHandle(itemdata.pos,1)
                        end,nil)
                    else
                        UseItemHandle(itemdata.pos,1)
                    end
                end
            elseif item_config.Type == const.TYPE_SEAL_ENERGY then
                if MyHeroManager.heroData.capture_energy >= MyHeroManager.heroData.energy_ceiling then
                    UIManager.ShowNotice(texttable.UIText[1101043].NR)
                else
                    UseItemHandle(itemdata.pos,1)
                end
            elseif item_config.Type == const.TYPE_CLEAR_PK_VALUE then
                if MyHeroManager.heroData.pk_value  <= 0 then
                    UIManager.ShowNotice(texttable.UIText[1101047].NR)
                else
                    UseItemHandle(itemdata.pos,1)
                end
            elseif item_config.Type == const.TYPE_SCALE_MODEL then
                local hero = SceneManager.GetEntityManager().hero
                if hero ~= nil then
                    if hero.disguise_model_id ~= nil and hero.disguise_model_scale  ~= 100 then
                        UIManager.ShowDialog(texttable.UIText[1101048].NR,texttable.UIText[1101006].NR,texttable.UIText[1101007].NR,function()
                                UseItemHandle(itemdata.pos,1)
                            end,nil)
                    else
                        UseItemHandle(itemdata.pos,1)
                    end
                end
            elseif item_config.Type == const.TYPE_DISGUISE_MODEL then
                local hero = SceneManager.GetEntityManager().hero
                if hero ~= nil then
                    if hero.disguise_model_id ~= nil then
                        UIManager.ShowDialog(texttable.UIText[1101049].NR,texttable.UIText[1101006].NR,texttable.UIText[1101007].NR,function()
                                UseItemHandle(itemdata.pos,1)
                            end,nil)
                    else
                        UseItemHandle(itemdata.pos,1)
                    end
                end
            elseif item_config.Type == const.TYPE_STEALTHY_CHARACTER then
                local hero = SceneManager.GetEntityManager().hero
                if hero ~= nil then
                    if hero.is_stealthy ~= nil and hero.is_stealthy then
                        UIManager.ShowDialog(texttable.UIText[1101058].NR,texttable.UIText[1101006].NR,texttable.UIText[1101007].NR,function()
                                UseStealthyItem(itemdata.pos,1)
                            end,nil)
                    else
                        UseStealthyItem(itemdata.pos,1)
                    end
                end
            elseif item_config.Type == const.TYPE_RANDOM_TRANSPORT_CHARACTER then
                if SceneManager.GetEntityManager().hero:CheckOperationStatus(const.HERO_OPERATION_STATUS.None) == true then
                    SceneManager.GetEntityManager().hero:ConveyRandom(itemdata.pos)
                    UIManager.UnloadView(ViewAssets.RoleUI)
                    UIManager.UnloadView(ViewAssets.BagUI)
                    BagManager.lock = true
                else
                    SceneManager.GetEntityManager().hero:ShowOperationStatus()
                end
            elseif item_config.Type == const.TYPE_NIL_TRANSPORT_BANNER then
                local scene_config = GetConfig("common_scene").MainScene[SceneManager.GetCurServerSceneId()]
                if scene_config ~= nil and MainDungeonManager.IsOnDungeoning() == false then
                    if SceneManager.GetEntityManager().hero:CheckOperationStatus(const.HERO_OPERATION_STATUS.None) == true then
                        SceneManager.GetEntityManager().hero:LocatePosition(itemdata.pos,itemdata.item_data.id)
                        UIManager.UnloadView(ViewAssets.RoleUI)
                        UIManager.UnloadView(ViewAssets.BagUI)
                        BagManager.lock = true
                    else
                        SceneManager.GetEntityManager().hero:ShowOperationStatus()
                    end
                else
                    UIManager.ShowNotice(texttable.UIText[1101054].NR)
                end
            elseif item_config.Type == const.TYPE_TRANSPORT_BANNER then
                local scene_config = GetConfig("common_scene").MainScene[SceneManager.GetCurServerSceneId()]
                if scene_config ~= nil and MainDungeonManager.IsOnDungeoning() == false then
                    if SceneManager.GetEntityManager().hero:CheckOperationStatus(const.HERO_OPERATION_STATUS.None) == true then
                        SceneManager.GetEntityManager().hero:ConveyBanner(itemdata.pos)
                        UIManager.UnloadView(ViewAssets.RoleUI)
                        UIManager.UnloadView(ViewAssets.BagUI)
                        BagManager.lock = true
                    else
                        SceneManager.GetEntityManager().hero:ShowOperationStatus()
                    end
                else
                    UIManager.ShowNotice(texttable.UIText[1101054].NR)
                end
            elseif item_config.Type == const.TYPE_CHANGE_NAME then
                local current_server_time = MyHeroManager.clientServerTimeDelta + networkMgr:GetConnection():GetSecondTimestamp()
                local delay = MyHeroManager.heroData.next_change_name_time - current_server_time
                if delay > 0 then
                    local day = math.floor(delay/86400)
                    delay = delay%86400
                    local hour = math.floor(delay/3600)
                    delay = delay%3600
                    local min = math.floor(delay/60)
                    delay = delay%60
                    local second = delay
                    UIManager.ShowNotice(string.format(texttable.UIText[1101059].NR,day,hour,min,second))
                else
                    UIManager.PushView(ViewAssets.ModifyNameUI,nil,itemdata.pos,itemdata.item_data.id)
                end
            elseif item_config.Type == const.TYPE_EFFECT_ITEM then
                local heroPosition = SceneManager.GetEntityManager().hero:GetPosition()
                if heroPosition ~= nil then
                    MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GAME_RPC, {func_name="on_use_effect_item",item_pos=itemdata.pos,posX=math.floor(heroPosition.x*100),posY=math.floor(heroPosition.y*100),posZ=math.floor(heroPosition.z*100)})
                    UIManager.UnloadView(ViewAssets.RoleUI)
                    UIManager.UnloadView(ViewAssets.BagUI)
                end
            elseif item_config.Type == const.TYPE_RECOVERY_DRUG then
                local drug_type = math.floor(item_config.Para1)
                if BagManager.CheckDrugCD(drug_type) then
                    MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GAME_RPC, {func_name="on_use_recovery_drug",item_pos=itemdata.pos,count=1})
                else
                    UIManager.ShowNotice(texttable.UIText[1101071].NR)
                end
			elseif item_config.Type == constant.TYPE_HEAD_FASHION or item_config.Type == constant.TYPE_CLOTH_FASHION or item_config.Type == constant.TYPE_WEAPON_FASHION or item_config.Type == TYPE_ORNAMENT_FASHION then
                local fashion_id = math.floor(item_config.Para1)
				if MyHeroManager.heroData.fashion_inventory[fashion_id] ~= nil then
				    UIManager.ShowDialog(texttable.UIText[1135027].NR, texttable.UIText[1101006].NR, texttable.UIText[1101007].NR, function() UseItemHandle(itemdata.pos,1) end,nil)
				  else
					 UseItemHandle(itemdata.pos,1)
                end
            elseif item_config.Type == const.TYPE_CHAOS_STONE then
                for k,v in pairs(gemTable.GemLevel) do
                    if v.TestItem == itemdata.item_data.id then
                        if not LuaUIUtil.CostItem(v.TestCost[1],v.TestCost[2],true) then
                            return
                        end
                        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GEM_IDENTIFY,{item_pos = itemdata.pos})
                    end
                end
            else
                UseItemHandle(itemdata.pos,1)
            end

        end
        UIManager.UnloadView(ViewAssets.ItemTipsUI)
    end

    --批量使用、合成
    local OnBatchUseBtnClick = function()
        if BagManager.lock == true then
            UIManager.ShowNotice(texttable.UIText[1101056].NR)
            return
        end
        UIManager.UnloadView(ViewAssets.ItemTipsUI)
    end

    local SplitItem = function(splitCount)
        if BagManager.lock == true then
            UIManager.ShowNotice(texttable.UIText[1101056].NR)
            return
        end
        if not itemdata.from == ItemTipsFromType then
            return
        end
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ITEM_SPLIT, {item_pos=itemdata.pos,count=splitCount})
    end

    local OnSplitBtnClick = function()
        if not itemdata.from == ItemTipsFromType then
            return
        end

        local posdata = BagManager.items[itemdata.pos]
        if not posdata then
            return
        end

        if posdata.count < 2 then
            return
        end

        if not UIManager.GetCtrl(ViewAssets.KeyBoardUI).isLoaded then
            UIManager.PushView(ViewAssets.KeyBoardUI,nil,{maxCount = posdata.count - 1,callbackHandler=SplitItem})
        else
            UIManager.GetCtrl(ViewAssets.KeyBoardUI).UpdateData({maxCount = posdata.count - 1,callbackHandler=SplitItem})
        end
        
        UIManager.UnloadView(ViewAssets.ItemTipsUI)
    end

    local OnCloseBtnClick = function()
        UIManager.UnloadView(ViewAssets.ItemTipsUI)
    end

    self.onLoad = function(callback)
        self.textTitle = self.view.texttitle:GetComponent("TextMeshProUGUI")
        self.textType = self.view.texttype:GetComponent("TextMeshProUGUI")
        self.textDescription = self.view.textdescribe:GetComponent("TextMeshProUGUI")
        self.textAcquire = self.view.textaccess:GetComponent("TextMeshProUGUI")
        self.textLevel = self.view.textUseLevel:GetComponent("TextMeshProUGUI")
        self.imgIcon = self.view.equipment:GetComponent("Image")
        self.imgQuality = self.view.imageQuality:GetComponent("Image")
        self.text1 = self.view.text1:GetComponent("TextMeshProUGUI")

        --使用、强化等
        self.textUseBtn = self.view.textstrengthen:GetComponent("TextMeshProUGUI")
        --合成
        self.textCombineBtn = self.view.textsynthetic:GetComponent("TextMeshProUGUI")
        --拆分
        self.textSplitBtn = self.view.textBreakUp:GetComponent("TextMeshProUGUI")
        self.view.bgmask:SetActive(false)
        ClickEventListener.Get(self.view.btnstrengthen).onClick = OnUseBtnClick
        ClickEventListener.Get(self.view.btnsynthetic).onClick = OnBatchUseBtnClick
        ClickEventListener.Get(self.view.btnBreakUp).onClick = OnSplitBtnClick
        ClickEventListener.Get(self.view.btnClose).onClick = OnCloseBtnClick
        ClickEventListener.Get(self.view.bgmask).onClick = OnCloseBtnClick
        self.view.transform.anchoredPosition3D = Vector3.New(self.view.transform.anchoredPosition3D.x,self.view.transform.anchoredPosition3D.y,-10)
        if callback ~= nil then
            callback()
        end
    end

    --更新数据,这个tips只显示物品
    --data.from 来源
    --data.pos 背包中的位置,目前背包使用
    --data.id 物品id
    --data.item_data 物品数据
    self.UpdateData = function(data)
        if data.item_data == nil or data.item_data.id == nil then
            return
        end

        itemdata = data

        local itemconfig = itemtable.Item[data.item_data.id]
        --目前只有背包
        self.textTitle.text = LuaUIUtil.GetItemName(data.item_data.id)
        self.textType.text = string.format(texttable.UIText[1101015].NR,"")
        self.textAcquire.text = string.format(texttable.UIText[1101017].NR,"")
        self.textDescription.text = string.format(texttable.UIText[1101016].NR,localization.GetItemDescription(data.item_data.id))
        self.textLevel.text = string.format(texttable.UIText[1101019].NR,itemconfig.LevelLimit)
        if MyHeroManager.heroData.level < itemconfig.LevelLimit then
            self.textLevel.color = Color.New(1,0,0)
        else
            self.textLevel.color = Color.New(26/255,24/255,29/255)
        end
        self.imgIcon.overrideSprite = LuaUIUtil.GetItemIcon(data.item_data.id)
        self.imgQuality.overrideSprite = LuaUIUtil.GetItemQuality(data.item_data.id)
        self.textUseBtn.text = texttable.UIText[1101012].NR
        self.textCombineBtn.text = texttable.UIText[1101001].NR
        self.textSplitBtn.text = texttable.UIText[1101013].NR

        --使用按钮
        self.view.btnstrengthen:SetActive(data.from == ItemTipsFromType.BAG and not BagManager.sellFlag)
        self.view.textstrengthen:SetActive(data.from == ItemTipsFromType.BAG and not BagManager.sellFlag)
        if itemconfig.Type == const.TYPE_CHAOS_STONE then
            self.textUseBtn.text = texttable.UIText[1114106].NR
        end
        self.view.btnsynthetic:SetActive(data.from == ItemTipsFromType.BAG and itemconfig.Type ~= const.TYPE_CHAOS_STONE and not BagManager.sellFlag)
        self.view.textsynthetic:SetActive(data.from == ItemTipsFromType.BAG and itemconfig.Type ~= const.TYPE_CHAOS_STONE and not BagManager.sellFlag)
        self.view.btnBreakUp:SetActive(data.from == ItemTipsFromType.BAG and not BagManager.sellFlag)
        self.view.textBreakUp:SetActive(data.from == ItemTipsFromType.BAG and not BagManager.sellFlag)
        self.text1.text = ""
        if data.item_data.location ~= nil then
            local scene_config = GetConfig("common_scene").MainScene[data.item_data.location.scene_id]
            if scene_config ~= nil then
                self.text1.text = string.format(texttable.UIText[1101057].NR,LuaUIUtil.GetTextByID(GetConfig("common_scene").MainScene[data.item_data.location.scene_id],'Name'),data.item_data.location.x/100,data.item_data.location.z/100,data.item_data.location.count)
            end
        end
    end

    self.SetBgMaskActive = function(value)
		if value == true then
			self.view.bgmask:SetActive(true)
		else
			self.view.bgmask:SetActive(false)
		end
    end

    self.UpdatePosition = function(x,y)
		self.view.transform.anchoredPosition3D = Vector3.New(x,y,0)
	end

    return self
end

return CreateItemTipsUICtrl()


