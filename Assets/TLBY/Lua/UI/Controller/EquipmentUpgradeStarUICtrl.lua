--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/20 0020
-- Time: 15:57
-- To change this template use File | Settings | File Templates.
--

require "UI/Controller/LuaCtrlBase"
require "UI/TextAnchor"
require "Logic/Bag/QualityConst"
require "UI/UIGrayMaterial"

local texttable = require "Logic/Scheme/common_char_chinese"
local itemtable = require "Logic/Scheme/common_item"
local upgradestartable = require "Logic/Scheme/equipment_star"
local const = require "Common/constant"
local localization = require "Common/basic/Localization"

local uitext = texttable.UIText
local itemconfigs = itemtable.Item
local upgradestarcost = upgradestartable.Bless
local equip_type_to_name = const.equip_type_to_name
local equip_name_to_type = const.equip_name_to_type

local max_exp_length = 415
local max_exp_length1 = 388

local function CreateEquipmentUpgradeStarUICtrl()
    local self = CreateCtrlBase()
    --服务器返回后先等待特效播放
    self.isReply = false
    local curSelectBlessItemId = 0
    --经验飘字延迟
    local timer1 = nil
    --经验缓动循环
    local timer2 = nil
    --特效计时器
    local effectTimer = nil
    --特效圆球位置
    local glowPosition1 = Vector3.New(11,-261,0)
    local glowPosition2 = Vector3.New(0,0,0)
    --星星标准位置
    local darkPosition = Vector3.New(235,187,0)
    local starPosition = Vector3.New(-37,-97.6,0)

    local function OnCloseBtnClick()
        UIManager.UnloadView(ViewAssets.EquipmentUI)
    end

    local function OnHelpBtnClick()
        UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
            ctrl.UpdateMsg(texttable.UIText[1101040].NR)
        end)
    end

    local function OnSelectBelssItemHandler(data)
        curSelectBlessItemId = data
        self.UpdateView()
    end

    --祈福石
    local function OnAddBlessItem()
        UIManager.PushView(ViewAssets.PurchaseUI,function(ctrl)
            ctrl.UpdateData({items=BagManager.GetItemIdsByType(const.TYPE_EQUIP_STAR_BLESS),okHandler=OnSelectBelssItemHandler,title=uitext[1116003].NR})
        end)
    end

    local function OnUpgradeStarBtnClick()
        if self.isReply then
            return
        end

        local star = 0
        if BagManager.equipment_star and BagManager.equipment_star[BagManager.currentEquipSlot] then
            star = BagManager.equipment_star[BagManager.currentEquipSlot].star
        end
        if star >= MAX_STAR_LEVEL then
            UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
                ctrl.UpdateMsg(uitext[1125006].NR)
            end)
            
            return
        end

        local bless_config = upgradestarcost[star+1]
        if bless_config == nil then
            return
        end

         local blessItemConfig = itemconfigs[curSelectBlessItemId]
        if blessItemConfig == nil then
            UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
                ctrl.UpdateMsg(uitext[1125005].NR)
            end)
            return
        end

        local blessItemNumber = BagManager.GetItemNumberById(curSelectBlessItemId)
        if blessItemNumber < 1 then
            UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
                ctrl.UpdateMsg(string.format(uitext[1115016].NR,localization.GetItemName(curSelectBlessItemId)))
            end)
            
        end

        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_STAR_EQUIPMENT, {equip_type=equip_name_to_type[BagManager.currentEquipSlot],bless_id=curSelectBlessItemId})
    end

    local function StopEffect()
        Timer.Remove(effectTimer)
        effectTimer = nil
        self.view.effectUpgradeStar:SetActive(false)
        self.view.glow_common:SetActive(false)
        self.view.shengxing_critical:SetActive(false)
        self.view.shengxing_star:SetActive(false)
    end

    local function OnEquipmentUpgradeStarReply(data)
        if data.result == 0 then
            if data.result == 0 then
                BagManager.dressing = true
                BagManager.propertyDelay = 2.8
            end
            self.isReply = true
            local currentExp = 0
            local star = 0
            if BagManager.equipment_star and BagManager.equipment_star[BagManager.currentEquipSlot] then
                currentExp = BagManager.equipment_star[BagManager.currentEquipSlot].exp
                star = BagManager.equipment_star[BagManager.currentEquipSlot].star
            end
            local function exp_move()
                local nextstarconfig = upgradestarcost[star+1]
                local count = 100*data.addon_exp/nextstarconfig.exp
                if count < 10 then
                    count = 10
                elseif count > 40 then
                    count = 40
                end
                local step = data.addon_exp / count
                if data.addon_exp + currentExp > nextstarconfig.exp then
                    step = (nextstarconfig.exp - currentExp) / count
                end

                local currentCount = 0
                UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
                    ctrl.UpdateMsg("exp+"..data.addon_exp)
                end)
                
                Timer.Remove(effectTimer)
                effectTimer =Timer.Numberal(0.03,count,function()
                    --如果被关掉了？
                    if not UIManager.GetCtrl(ViewAssets.EquipmentUpgradeStarUI).isLoaded then
                        return
                    end
                    currentExp = currentExp + step
                    local explen = max_exp_length1*currentExp / nextstarconfig.exp
                    if explen >  max_exp_length1 then
                        explen = max_exp_length1
                    end
                    self.imgExpTransform1.sizeDelta = Vector2.New(explen,self.imgExpTransform1.sizeDelta.y)
                    currentCount = currentCount + 1
                    if currentCount >= count then
                        Timer.Remove(effectTimer)
                        if data.success == 1 then
                            self.view.shengxing_star:SetActive(true)
                            self.view.shengxing_star.transform.localPosition = starPosition + (self.view.darkstar.transform.localPosition - darkPosition)*7/12
                            self.imgExpTransform.sizeDelta = Vector2.New(0,self.imgExpTransform.sizeDelta.y)
                            self.imgExpTransform1.sizeDelta = Vector2.New(0,self.imgExpTransform1.sizeDelta.y)
                            effectTimer = Timer.Delay(1,function()
                                if data.current_exp > 0 and data.star < MAX_STAR_LEVEL then
                                    Timer.Remove(effectTimer)
                                    local starconfig = upgradestarcost[data.star+1]
                                    local cnt = 100*data.addon_exp/nextstarconfig.exp
                                    if cnt < 10 then
                                        cnt = 10
                                    elseif cnt > 40 then
                                        cnt = 40
                                    end
                                    local step = data.current_exp / cnt
                                    if data.current_exp > starconfig.exp then
                                        step = starconfig.exp / cnt
                                    end
                                    local ccnt = 0
                                    self.textExp.text = data.current_exp.."/"..nextstarconfig.exp
                                    effectTimer =Timer.Numberal(0.03,cnt,function()
                                        --如果被关掉了？
                                        if not UIManager.GetCtrl(ViewAssets.EquipmentUpgradeStarUI).isLoaded then
                                            return
                                        end

                                        local explen = max_exp_length1*step*ccnt / starconfig.exp
                                        if explen >  max_exp_length1 then
                                            explen = max_exp_length1
                                        end
                                        self.imgExpTransform1.sizeDelta = Vector2.New(explen,self.imgExpTransform1.sizeDelta.y)
                                        ccnt = ccnt + 1
                                        if ccnt >= cnt then
                                            Timer.Remove(effectTimer)
                                            self.isReply = false
                                            self.UpdateView()
                                            StopEffect()
                                        end
                                    end)
                                else
                                    self.view.shengxing_star:SetActive(false)
                                    self.isReply = false
                                    self.UpdateView()
                                    StopEffect()
                                end
                            end)
                        else
                            self.isReply = false
                            self.UpdateView()
                            StopEffect()
                        end
                    end
                end)
            end
            StopEffect()
            self.view.effectUpgradeStar:SetActive(true)
            self.view.glow_common:SetActive(true)
            local glow_count = 21
            local current_glow_count = 0
            self.view.glow_common.transform.localPosition = glowPosition1
            --暴击
            if data.crit > 1 then
                UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
                    ctrl.UpdateMsg(string.format(uitext[1115024].NR,data.crit))
                end)
                
            end
            effectTimer = Timer.Numberal(0.03,glow_count,function()
                self.view.glow_common.transform.localPosition = glowPosition1 + (glowPosition2 - glowPosition1)*current_glow_count/glow_count
                current_glow_count = current_glow_count + 1
                if current_glow_count >= glow_count then
                    self.view.glow_common:SetActive(false)
                    self.view.glow_common.transform.localPosition = glowPosition1
                    if data.upgrade ~= nil and data.upgrade == 1 then
                        Timer.Remove(effectTimer)
                        self.view.shengxing_critical:SetActive(true)
                        effectTimer = Timer.Delay(1,function()
                            self.view.shengxing_critical:SetActive(false)
                            exp_move()
                        end)
                    else
                        exp_move()
                    end
                end
            end)
        end
    end

    local function OnStrengthenEquipmentClick()
        BagManager.ShowItemTips({from=ItemTipsFromType.EQUIPMENT,pos=BagManager.currentEquipSlot,item_data=BagManager.equipments[BagManager.currentEquipSlot]},true)
    end

    self.onLoad = function()
        --升星按钮
        self.textUpgradeStarBtn = self.view.textdetermine:GetComponent("TextMeshProUGUI")
        --UIUtil.AddTextOutline(self.view.textdetermine,Color.New(255/255,222/255,191/255))
        self.view.textdetermine:GetComponent("RectTransform").sizeDelta = Vector2.New(90,45)
        self.textUpgradeStarBtn.text = uitext[1115002].NR
        self.imgUpgradeStarBtn = self.view.btndetermine:GetComponent("Image")
        UIUtil.AddButtonEffect(self.view.btndetermine,nil,nil)

        --装备图标
        self.imgEquipment = self.view.iconStrengthenstone2:GetComponent("Image")
        self.imgEquipmentQuality = self.view.iconStrengthenstoneQuality2:GetComponent("Image")
        --经验值
        self.textExp = self.view.textstarexparticle:GetComponent("TextMeshProUGUI")
        self.view.textstarexparticle:GetComponent("RectTransform").sizeDelta = Vector2.New(300,41)
        --经验条
        self.imgExpTransform = self.view.bgstarexparticle:GetComponent("RectTransform")
        self.imgExpTransform1 = self.view.bgstarexparticle1:GetComponent("RectTransform")
        --星星
        self.stars = {}
        for i=1,9,1 do
            self.stars[i] = {}
            self.stars[i].obj = self.view["star"..i]
            self.stars[i].transform = self.stars[i].obj:GetComponent("RectTransform")
        end
        self.darkStar = self.view.darkstar
        self.darkStarTransform = self.darkStar:GetComponent("RectTransform")
        --祈福石
        self.imgBlessItem = self.view.iconPrayermaterial:GetComponent("Image")
        self.imgBlessItemQuality = self.view.iconPrayermaterialQuality:GetComponent("Image")
        --祈福石数量
        self.textBlessNumber = self.view.textblessnumber:GetComponent("TextMeshProUGUI")
        --添加祈福石
        self.btnAddBlessItem = self.view.btnPrayermaterialadd
        --祈福石说明
        self.textDescription = self.view.textBlessingdescribe:GetComponent("TextMeshProUGUI")

        ClickEventListener.Get(self.view.btnclose).onClick = OnCloseBtnClick
        -- ClickEventListener.Get(self.view.btnpagingstrengthen).onClick = OnStrengthenTabClick
        -- ClickEventListener.Get(self.view.btnsmelting).onClick = OnSmeltingTabClick
        -- ClickEventListener.Get(self.view.gemgem).onClick = OnGemTabClick
        --ClickEventListener.Get(self.view.btnrules).onClick = OnHelpBtnClick
        ClickEventListener.Get(self.view.iconPrayermaterial).onClick = OnAddBlessItem
        ClickEventListener.Get(self.view.btnPrayermaterialadd).onClick = OnAddBlessItem
        ClickEventListener.Get(self.view.btndetermine).onClick = OnUpgradeStarBtnClick
        ClickEventListener.Get(self.view.iconStrengthenstone2).onClick = OnStrengthenEquipmentClick

        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_STAR_EQUIPMENT,OnEquipmentUpgradeStarReply)
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

        local star = 0
        local exp = 0
        if BagManager.equipment_star ~= nil and BagManager.equipment_star[BagManager.currentEquipSlot] ~= nil then
            star = BagManager.equipment_star[BagManager.currentEquipSlot].star
            exp = BagManager.equipment_star[BagManager.currentEquipSlot].exp
        end

        local nextstarconfig = upgradestarcost[star+1]
        if nextstarconfig == nil then
            if star == MAX_STAR_LEVEL then
                nextstarconfig = upgradestarcost[star]
                if nextstarconfig == nil then
                    return
                end
            else
                return
            end
        end

        --装备
        self.imgEquipment.overrideSprite = ResourceManager.LoadSprite("ItemIcon/"..itemconfig.Icon)
        self.imgEquipmentQuality.overrideSprite = ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(itemconfig.Quality))
        --经验
        if star >= MAX_STAR_LEVEL then
            self.textExp.text = "MAX"
            self.imgExpTransform.sizeDelta = Vector2.New(max_exp_length,self.imgExpTransform.sizeDelta.y)
            self.imgExpTransform1.sizeDelta = Vector2.New(max_exp_length1,self.imgExpTransform1.sizeDelta.y)
        else
            self.textExp.text = exp.."/"..nextstarconfig.exp
            local explen = max_exp_length*exp / nextstarconfig.exp
            if explen > max_exp_length then
                explen = max_exp_length
            end
            self.imgExpTransform.sizeDelta = Vector2.New(explen,self.imgExpTransform.sizeDelta.y)
            local explen1 = max_exp_length1*exp / nextstarconfig.exp
            if explen1 > max_exp_length1 then
                explen1 = max_exp_length1
            end
            self.imgExpTransform1.sizeDelta = Vector2.New(explen1,self.imgExpTransform1.sizeDelta.y)
        end

        --星星
        if star == 0 and exp == 0 then
            for i,v in pairs(self.stars) do
                self.stars[i].obj:SetActive(false)
            end
            self.darkStar:SetActive(false)
            self.darkStarTransform.anchoredPosition3D = Vector3.New(307,187,0)
        else
            local count = 0

            if star < MAX_STAR_LEVEL then
                count = star + 1
                self.darkStar:SetActive(true)
            else
                self.darkStar:SetActive(false)
                count = star
            end
            local xInterval = 70
            local xPosition = 307 - xInterval*(count - 1)/2
            local yPosition = 187
            for i=1,star,1 do
                self.stars[i].obj:SetActive(true)
                self.stars[i].transform.anchoredPosition3D = Vector3.New(xPosition+xInterval*(i-1),yPosition,0)
            end
            for i=star+1,MAX_STAR_LEVEL,1 do
                self.stars[i].obj:SetActive(false)
            end
            self.darkStarTransform.anchoredPosition3D = Vector3.New(xPosition+xInterval*star,yPosition,0)
        end
        --祈福
        local canOperate = true
        local currentBlessItemConfig = itemconfigs[curSelectBlessItemId]
        if currentBlessItemConfig then
            self.view.iconPrayermaterial:SetActive(true)
            self.btnAddBlessItem:SetActive(false)
            self.imgBlessItem.overrideSprite = ResourceManager.LoadSprite("ItemIcon/"..currentBlessItemConfig.Icon)
            self.view.iconPrayermaterialQuality:SetActive(true)
            self.imgBlessItemQuality.overrideSprite = ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(currentBlessItemConfig.Quality))
            local currentNumber = BagManager.GetItemNumberById(curSelectBlessItemId)
            if currentNumber < 1 then
                self.textBlessNumber.text = string.format(uitext[1115020].NR,currentNumber,1)
                canOperate = false
            else
                self.textBlessNumber.text = string.format(uitext[1115019].NR,currentNumber,1)
            end
        else
            self.view.iconPrayermaterial:SetActive(false)
            self.view.iconPrayermaterialQuality:SetActive(false)
            self.btnAddBlessItem:SetActive(true)
            self.textBlessNumber.text = ""
            canOperate = false
        end
        --祈福说明
        self.textDescription.text = uitext[1125001].NR

        if canOperate then
            self.imgUpgradeStarBtn.material = nil
            self.textUpgradeStarBtn.material = nil
        else
            self.imgUpgradeStarBtn.material = UIGrayMaterial.GetUIGrayMaterial()
            self.textUpgradeStarBtn.material = UIGrayMaterial.GetUIGrayMaterial()
        end
    end

    self.onUnload = function()
        self.isReply = false
        StopEffect()
    end

    return self
end

return CreateEquipmentUpgradeStarUICtrl()

