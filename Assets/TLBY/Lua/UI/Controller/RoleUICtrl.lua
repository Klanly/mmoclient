--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/9 0009
-- Time: 16:56
-- To change this template use File | Settings | File Templates.
--

require "UI/Controller/LuaCtrlBase"
require "Logic/Bag/ItemType"
require "UI/TextAnchor"
local texttable = require "Logic/Scheme/common_char_chinese"
local itemtable = require "Logic/Scheme/common_item"
local const = require "Common/constant"
local gemTable = require "Logic/Scheme/equipment_jewel"

    
local equip_type_to_name = const.equip_type_to_name
local itemconfigs = itemtable.Item

local function CreateRoleUICtrl()
    local self = CreateCtrlBase()
    self.rolemodel = nil

    local function ShowEquipTips(etype)
        BagManager.ShowItemTips({from=ItemTipsFromType.PLAYER,pos=etype,item_data=BagManager.equipments[etype]})
	end

    local function OnWeaponClick()
		ShowEquipTips("Weapon")
	end

	local function OnNecklaceClick()
		ShowEquipTips("Necklace")
	end

	local function OnRingClick()
		ShowEquipTips("Ring")
	end

	local function OnBootClick()
		ShowEquipTips("Boot")
	end

	local function OnHelmetClick()
		ShowEquipTips("Helmet")
	end

	local function OnLeggingClick()
		ShowEquipTips("Legging")
	end

	local function OnBeltClick()
		ShowEquipTips("Belt")
	end

	local function OnArmorClick()
		ShowEquipTips("Armor")
    end

    local function OnAddWeaponClick()
		BagManager.ShowCanUseEquip(const.TYPE_WEAPON)
	end

	local function OnAddNecklaceClick()
		BagManager.ShowCanUseEquip(const.TYPE_NECKLACE)
	end

	local function OnAddRingClick()
		BagManager.ShowCanUseEquip(const.TYPE_RING)
	end

	local function OnAddBootClick()
		BagManager.ShowCanUseEquip(const.TYPE_BOOT)
	end

	local function OnAddHelmetClick()
		BagManager.ShowCanUseEquip(const.TYPE_HELMET)
	end

	local function OnAddLeggingClick()
		BagManager.ShowCanUseEquip(const.TYPE_LEGGING)
	end

	local function OnAddBeltClick()
		BagManager.ShowCanUseEquip(const.TYPE_BELT)
	end

	local function OnAddArmorClick()
		BagManager.ShowCanUseEquip(const.TYPE_ARMOR)
	end

    local function OnMasterBtnClick()
        UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
            ctrl.UpdateMsg(texttable.UIText[1101040].NR)
        end)        
    end

    self.onLoad = function()
        --玩家名字
        self.textPlayerName = self.view.textplayername:GetComponent("TextMeshProUGUI")
        --战斗力
        self.textFightPower = self.view.textfightdigital:GetComponent("TextMeshProUGUI")
        --灵力
        self.textSpiritual = self.view.textmagicdigital:GetComponent("TextMeshProUGUI")

        ClickEventListener.Get(self.view.iconequipmentitem1).onClick = OnHelmetClick
        ClickEventListener.Get(self.view.iconequipmentitem2).onClick = OnWeaponClick
        ClickEventListener.Get(self.view.iconequipmentitem3).onClick = OnArmorClick
        ClickEventListener.Get(self.view.iconequipmentitem4).onClick = OnBootClick
        ClickEventListener.Get(self.view.iconequipmentitem5).onClick = OnNecklaceClick
        ClickEventListener.Get(self.view.iconequipmentitem6).onClick = OnRingClick
        ClickEventListener.Get(self.view.iconequipmentitem7).onClick = OnBeltClick
        ClickEventListener.Get(self.view.iconequipmentitem8).onClick = OnLeggingClick

        --ClickEventListener.Get(self.view.btncloth_).onClick = OnAddFashionClick
        ClickEventListener.Get(self.view.btnclose).onClick = self.close
        ClickEventListener.Get(self.view.btnMasterr).onClick = OnMasterBtnClick
        ClickEventListener.Get(self.view.btnbag).onClick = function() self.ShowTab(RoleUITab.BAG) end
        ClickEventListener.Get(self.view.btnattribute).onClick = function() self.ShowTab(RoleUITab.ATTRIBUTE) end
        ClickEventListener.Get(self.view.btninfor).onClick = function() self.ShowTab(RoleUITab.INFO) end
        self.ShowTab(RoleUITab.BAG)
    end
    
    self.onUnload = function()
        BagManager.CloseItemTips()
        UIManager.UnloadView(ViewAssets.RoleappearanceUI)
        UIManager.UnloadView(ViewAssets.BagUI)
        UIManager.UnloadView(ViewAssets.RoleAttributeUI)
    end


    self.ShowTab = function(tab)
        if tab == RoleUITab.BAG then
            UIManager.UnloadView(ViewAssets.RoleAttributeUI)
            UIManager.UnloadView(ViewAssets.RoleappearanceUI)
            if not UIManager.GetCtrl(ViewAssets.BagUI).isLoaded then
            self.view.btnbag:GetComponent('Toggle').isOn = true
            UIManager.PushView(ViewAssets.BagUI)
            end
        elseif tab == RoleUITab.ATTRIBUTE then
            UIManager.UnloadView(ViewAssets.RoleappearanceUI)
            UIManager.UnloadView(ViewAssets.BagUI)
            if not UIManager.GetCtrl(ViewAssets.RoleAttributeUI).isLoaded then
            self.view.btnattribute:GetComponent('Toggle').isOn = true
            UIManager.PushView(ViewAssets.RoleAttributeUI)
            end
        elseif tab == RoleUITab.INFO then
            -- UIManager.UnloadView(ViewAssets.RoleAttributeUI)
            -- UIManager.UnloadView(ViewAssets.BagUI)
            -- if not UIManager.GetCtrl(ViewAssets.RoleappearanceUI).isLoaded then
            -- self.view.btninfor:GetComponent('Toggle').isOn = true
            self.close()
            UIManager.PushView(ViewAssets.RoleappearanceUI, function(ctrl)
                ctrl.preAssetUI = ViewAssets.RoleUI
            end)
        else
            if not UIManager.GetCtrl(ViewAssets.BagUI).isLoaded then
                UIManager.PushView(ViewAssets.BagUI)
            end
        end
        self.UpdateView()
    end

    self.RemoveRoleModel = function()
        RecycleObject(self.rolemodel)
        self.rolemodel = nil
    end

    self.UpdateView = function()
        if not self.isLoaded then return end
        
        self.textFightPower.text = MyHeroManager.heroData.fight_power
        self.textSpiritual.text = MyHeroManager.heroData.property[const.PROPERTY_NAME_TO_INDEX.spritual]
        self.textPlayerName.text = MyHeroManager.heroData.actor_name
        self.RemoveRoleModel()
		local HeadFashionId =  SceneManager.GetEntityManager().hero.appearance_1
		local ClothFashionId  = SceneManager.GetEntityManager().hero.appearance_2
		local WeaponFashionId  = SceneManager.GetEntityManager().hero.appearance_3
        LuaUIUtil.GetHeroModel(MyHeroManager.heroData.vocation,MyHeroManager.heroData.sex,function(obj)
		  self.rolemodel = obj
		  self.rolemodel.transform.position = Vector3.New(0,0,0)
          self.rolemodel.transform:SetParent(self.view.rolemodel.transform,false)
          self.UpdateEqupments()
		end,HeadFashionId,ClothFashionId,WeaponFashionId)
    end

    --更新装备
    self.UpdateEqupments = function()
		if not self.view then
			return
		end

        local equipconfig = nil
        local equips = { 
            BagManager.equipments.Helmet,
            BagManager.equipments.Weapon,
            BagManager.equipments.Armor,
            BagManager.equipments.Boot,
            BagManager.equipments.Necklace,
            BagManager.equipments.Ring,        
            BagManager.equipments.Belt,
            BagManager.equipments.Legging,
            
        }
        for i=1,8 do
            if equips[i] then
                self.view['btnequipmentadd'..i]:SetActive(false)
                equipconfig = itemtable.Item[equips[i].id]
                if equipconfig then
                    self.view['iconequipmentitem'..i]:SetActive(true)
                    self.view['iconequipmentitem'..i]:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(equips[i].id)
                    self.view['Frame'..i]:GetComponent('Image').overrideSprite = ResourceManager.LoadSprite(string.format("AutoGenerate/RoleUI/Frame%d",equipconfig.Quality))
                    self.view['number'..i]:GetComponent('TextMeshProUGUI').text = equipconfig.LevelLimit
                else
                    self.view['iconequipmentitem'..i]:SetActive(true)
                end
            else
                self.view['iconequipmentitem'..i]:SetActive(false)
                self.view['btnequipmentadd'..i]:SetActive(true)
            end
        end
	end

    return self
end

return CreateRoleUICtrl()

