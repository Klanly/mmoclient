--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/20 0020
-- Time: 15:41
-- To change this template use File | Settings | File Templates.
--

require "UI/Controller/LuaCtrlBase"
require "UI/TextAnchor"
require "Logic/Entity/Attribute/AttributeConst"

local texttable = require "Logic/Scheme/common_char_chinese"

local uitext = texttable.UIText

local function CreateEquipmentUICtrl()
    local self = CreateCtrlBase()
    local Weapon = {}
    local Necklace = {}
    local Ring = {}
    local Helmet = {}
    local Armor = {}
    local Belt = {}
    local Legging = {}
    local Boot = {}
    --背包装备
    local items = {}

    --计算装备列表高度
    local scrollContentHeight = 10
    --计算列表索引
    local elementIndex = 0
    
    self.onLoad = function()
        --UIUtil.SetTextAlignment(self.textTitle,TextAnchor.MiddleCenter)
        self.scrollViewContentTransform = self.view.Content:GetComponent("RectTransform")
        for i = 1,4 do
            self.AddClick(self.view['tab'..i],function() self.ShowTab(i) end)      
        end
        self.ShowTab(BagManager.currentEquipTab)
        BagManager.CloseRoleUI()
    end

    self.ShowTab = function(tab)

        UIManager.UnloadView(ViewAssets.EquipmentSmeltingUI)
        UIManager.UnloadView(ViewAssets.EquipGemUI)
        UIManager.UnloadView(ViewAssets.EquipmentUpgradeStarUI)
        UIManager.UnloadView(ViewAssets.EquipmentStrengthenUI)

        BagManager.currentEquipTab = tab
        self.view.tabLight.transform.position = self.view['tab'..tab].transform.position
        self.view.generalbox:SetActive(tab ~= EquipmentUITab.GEM)
        if tab == EquipmentUITab.STRENGTHEN then
            UIManager.PushView(ViewAssets.EquipmentStrengthenUI,function(ctrl)
                self.UpdateView()
                ctrl.isReply = false
            end)
        elseif tab == EquipmentUITab.UPGRADESTAR then
            UIManager.PushView(ViewAssets.EquipmentUpgradeStarUI,function(ctrl)
                self.UpdateView()
                ctrl.isReply = false
            end)
        elseif tab == EquipmentUITab.SMELTING then
            UIManager.PushView(ViewAssets.EquipmentSmeltingUI,function(ctrl)
                self.UpdateView()
                ctrl.isReply = false
            end )
        elseif tab == EquipmentUITab.GEM then
            UIManager.PushView(ViewAssets.EquipGemUI)
        else
            UIManager.PushView(ViewAssets.EquipmentStrengthenUI,self.UpdateView)
        end
        --self.UpdateView()
    end

    self.UpdateView = function()
        self.UpdateEquipList()
        if BagManager.currentEquipTab == EquipmentUITab.STRENGTHEN then
            if UIManager.GetCtrl(ViewAssets.EquipmentStrengthenUI).isLoaded then
                UIManager.GetCtrl(ViewAssets.EquipmentStrengthenUI).UpdateView()
            end
        elseif BagManager.currentEquipTab == EquipmentUITab.UPGRADESTAR then
            if UIManager.GetCtrl(ViewAssets.EquipmentUpgradeStarUI).isLoaded then
                UIManager.GetCtrl(ViewAssets.EquipmentUpgradeStarUI).UpdateView()
            end
        elseif BagManager.currentEquipTab == EquipmentUITab.SMELTING then
            if UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).isLoaded then
                UIManager.GetCtrl(ViewAssets.EquipmentSmeltingUI).UpdateView()
            end
        end
    end
    self.UpdateEquipList = function()
        scrollContentHeight = 10
        elementIndex = 1
        if BagManager.equipments.Weapon then
            self.AddEquipmentSlot(Weapon,function(data)
                Weapon = data
                Weapon.table.SetData("Weapon",BagManager.equipments.Weapon.id,BagManager.currentEquipTab)
            end)
        else
            self.RemoveEquipmentSlot(Weapon)
        end

        if BagManager.equipments.Necklace then
            self.AddEquipmentSlot(Necklace,function(data)
                Necklace = data
                Necklace.table.SetData("Necklace",BagManager.equipments.Necklace.id,BagManager.currentEquipTab)
            end)
        else
            self.RemoveEquipmentSlot(Necklace)
        end

        if BagManager.equipments.Ring then
            self.AddEquipmentSlot(Ring,function(data)
                Ring = data
                Ring.table.SetData("Ring",BagManager.equipments.Ring.id,BagManager.currentEquipTab)
            end)
        else
            self.RemoveEquipmentSlot(Ring)
        end

        if BagManager.equipments.Helmet then
            self.AddEquipmentSlot(Helmet,function(data)
                Helmet = data
                Helmet.table.SetData("Helmet",BagManager.equipments.Helmet.id,BagManager.currentEquipTab)
            end)
        else
            self.RemoveEquipmentSlot(Helmet)
        end

        if BagManager.equipments.Armor then
            self.AddEquipmentSlot(Armor,function(data)
                Armor = data
                Armor.table.SetData("Armor",BagManager.equipments.Armor.id,BagManager.currentEquipTab)
            end)
        else
            self.RemoveEquipmentSlot(Armor)
        end

        if BagManager.equipments.Belt then
            self.AddEquipmentSlot(Belt,function(data)
                Belt = data
                Belt.table.SetData("Belt",BagManager.equipments.Belt.id,BagManager.currentEquipTab)
            end)
        else
            self.RemoveEquipmentSlot(Belt)
        end

        if BagManager.equipments.Legging then
            self.AddEquipmentSlot(Legging,function(data)
                Legging = data
                Legging.table.SetData("Legging",BagManager.equipments.Legging.id,BagManager.currentEquipTab)
            end)
        else
            self.RemoveEquipmentSlot(Legging)
        end

        if BagManager.equipments.Boot then
            self.AddEquipmentSlot(Boot,function(data)
                Boot = data
                Boot.table.SetData("Boot",BagManager.equipments.Boot.id,BagManager.currentEquipTab)
            end)
        else
            self.RemoveEquipmentSlot(Boot)
        end

        if BagManager.currentEquipTab == EquipmentUITab.SMELTING then
            local bagitems = BagManager.GetEquipmets()
            local count = 0
            for i=1,#bagitems,1 do
                if items[i] == nil then
                    items[i] = {}
                end
                local current_equip_index = i
                self.AddEquipmentSlot(items[current_equip_index],function(data)
                    items[current_equip_index] = data
                    items[current_equip_index].table.SetData("bag",BagManager.items[bagitems[current_equip_index]].id,BagManager.currentEquipTab,bagitems[current_equip_index])
                end)
                count = count + 1
            end
            for i = count + 1,#items,1 do
                self.RemoveEquipmentSlot(items[i])
                items[i] = nil
            end
        else
            for i,_ in pairs(items) do
                self.RemoveEquipmentSlot(items[i])
                items[i] = nil
            end
            items = {}
        end

        if scrollContentHeight < 900 then
            scrollContentHeight = 900
        end

        self.scrollViewContentTransform.sizeDelta = Vector2.New(0,scrollContentHeight)
    end

    self.AddEquipmentSlot = function(data,callback)
        local current_height = scrollContentHeight
        local current_index = elementIndex
        elementIndex = elementIndex + 1
        scrollContentHeight = scrollContentHeight + 150
        if data == nil or data.obj == nil then
            ResourceManager.CreateUI("EquipmentSlotUI/EquipmentSlotUI",function(obj)
                local _data = {}
                _data.obj = obj
                _data.transform = _data.obj:GetComponent("RectTransform")
                _data.table = _data.obj:GetComponent("LuaBehaviour").luaTable
                _data.obj:SetActive(true)
                _data.index = current_index
                _data.transform:SetParent(self.scrollViewContentTransform,false)
                _data.transform.anchoredPosition3D = Vector3.New(0,- current_height -75,0)
                if callback ~= nil then
                    callback(_data)
                end
            end)
        else
            data.obj:SetActive(true)
            data.index = current_index
            data.transform:SetParent(self.scrollViewContentTransform,false)
            data.transform.anchoredPosition3D = Vector3.New(0,- current_height -75,0)
            if callback ~= nil then
                callback(data)
            end
        end
    end

    self.RemoveEquipmentSlot = function(data)
        if data and data.obj then
            RecycleObject(data.obj)
        end
        data = nil
    end

    self.onUnload = function()
        self.RemoveEquipmentSlot(Weapon)
        Weapon = {}
        self.RemoveEquipmentSlot(Necklace)
        Necklace = {}
        self.RemoveEquipmentSlot(Ring)
        Ring = {}
        self.RemoveEquipmentSlot(Helmet)
        Helmet = {}
        self.RemoveEquipmentSlot(Armor)
        Armor = {}
        self.RemoveEquipmentSlot(Belt)
        Belt = {}
        self.RemoveEquipmentSlot(Legging)
        Legging = {}
        self.RemoveEquipmentSlot(Boot)
        Boot = {}
        for i,_ in pairs(items) do
            self.RemoveEquipmentSlot(items[i])
            items[i] = nil
        end
        items = {}
        BagManager.currentEquipTab = EquipmentUITab.STRENGTHEN

        UIManager.UnloadView(ViewAssets.EquipmentStrengthenUI)
        UIManager.UnloadView(ViewAssets.EquipmentUpgradeStarUI)
        UIManager.UnloadView(ViewAssets.EquipmentSmeltingUI)
        UIManager.UnloadView(ViewAssets.EquipGemUI)
        UIManager.UnloadView(ViewAssets.PurchaseUI)
    end

    --设置滚动视图位置
    self.SetContentPosition = function()
        --只有六个装备以下，不需滚动
        if elementIndex <= 7 then
            return
        end

        if BagManager.currentEquipSlot == "Weapon" then
            if self.scrollViewContentTransform.anchoredPosition3D.y > 0 then
                self.scrollViewContentTransform.anchoredPosition3D = Vector3.New(self.scrollViewContentTransform.anchoredPosition3D.x,0,self.scrollViewContentTransform.anchoredPosition3D.z)
            end
        end

        if BagManager.currentEquipSlot == "Necklace" and Necklace ~= nil then
            if self.scrollViewContentTransform.anchoredPosition3D.y > 160*(Necklace.index - 1) then
                self.scrollViewContentTransform.anchoredPosition3D = Vector3.New(self.scrollViewContentTransform.anchoredPosition3D.x,160*(Necklace.index - 1),self.scrollViewContentTransform.anchoredPosition3D.z)
            end
        end

        if BagManager.currentEquipSlot == "Ring" and Ring ~= nil then
            if self.scrollViewContentTransform.anchoredPosition3D.y > 160*(Ring.index - 1) then
                self.scrollViewContentTransform.anchoredPosition3D = Vector3.New(self.scrollViewContentTransform.anchoredPosition3D.x,160*(Ring.index - 1),self.scrollViewContentTransform.anchoredPosition3D.z)
            end
        end

        if BagManager.currentEquipSlot == "Helmet" and Helmet ~= nil then
            if self.scrollViewContentTransform.anchoredPosition3D.y > 160*(Helmet.index - 1) then
                self.scrollViewContentTransform.anchoredPosition3D = Vector3.New(self.scrollViewContentTransform.anchoredPosition3D.x,160*(Helmet.index - 1),self.scrollViewContentTransform.anchoredPosition3D.z)
            end
        end

        if BagManager.currentEquipSlot == "Armor" and Armor ~= nil then
            if self.scrollViewContentTransform.anchoredPosition3D.y > 160*(Armor.index - 1) then
                self.scrollViewContentTransform.anchoredPosition3D = Vector3.New(self.scrollViewContentTransform.anchoredPosition3D.x,160*(Armor.index - 1),self.scrollViewContentTransform.anchoredPosition3D.z)
            end
        end

        if BagManager.currentEquipSlot == "Belt" and Belt ~= nil then
            if self.scrollViewContentTransform.anchoredPosition3D.y > 160*(Belt.index - 1) then
                self.scrollViewContentTransform.anchoredPosition3D = Vector3.New(self.scrollViewContentTransform.anchoredPosition3D.x,160*(Belt.index - 1),self.scrollViewContentTransform.anchoredPosition3D.z)
            end
        end

        if BagManager.currentEquipSlot == "Legging" and Legging ~= nil then
            if self.scrollViewContentTransform.anchoredPosition3D.y > 160*(Legging.index - 1) then
                self.scrollViewContentTransform.anchoredPosition3D = Vector3.New(self.scrollViewContentTransform.anchoredPosition3D.x,160*(Legging.index - 1),self.scrollViewContentTransform.anchoredPosition3D.z)
            elseif self.scrollViewContentTransform.anchoredPosition3D.y < 160*(Legging.index - 6) then
                self.scrollViewContentTransform.anchoredPosition3D = Vector3.New(self.scrollViewContentTransform.anchoredPosition3D.x,160*(Legging.index - 6),self.scrollViewContentTransform.anchoredPosition3D.z)
            end
        end

        if BagManager.currentEquipSlot == "Boot" and Boot ~= nil then
            if self.scrollViewContentTransform.anchoredPosition3D.y > 160*(Boot.index - 1) then
                self.scrollViewContentTransform.anchoredPosition3D = Vector3.New(self.scrollViewContentTransform.anchoredPosition3D.x,160*(Boot.index - 1),self.scrollViewContentTransform.anchoredPosition3D.z)
            elseif self.scrollViewContentTransform.anchoredPosition3D.y < 160*(Boot.index - 6) then
                self.scrollViewContentTransform.anchoredPosition3D = Vector3.New(self.scrollViewContentTransform.anchoredPosition3D.x,160*(Boot.index - 6),self.scrollViewContentTransform.anchoredPosition3D.z)
            end
        end
    end

    return self
end

return CreateEquipmentUICtrl()

