--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/9/20 0020
-- Time: 17:18
-- To change this template use File | Settings | File Templates.
--

require "Common/basic/LuaObject"
require "math"
require "Logic/Bag/QualityConst"
local itemTable = require "Logic/Scheme/common_item"
local texttable = require "Logic/Scheme/common_char_chinese"

local function CreateBagItemUI()
	local self = CreateViewBase()
    local pos = 1
    local data = nil;

	self.Awake = function()
        --品质
        self.imgQuality = self.transform:FindChild("Quality").gameObject:GetComponent("Image")
        self.goQuality = self.transform:FindChild("Quality").gameObject
        --锁
        self.goLock = self.transform:FindChild("Lock").gameObject
        --物品
        self.goIcon = self.transform:FindChild("Icon").gameObject
        self.imgIcon = self.transform:FindChild("Icon").gameObject:GetComponent("Image")
        --数量
        self.numberTxt = self.transform:FindChild("Number").gameObject:GetComponent("TextMeshProUGUI")
        --不可出售
        self.sellFlag = self.transform:FindChild("SellFlag").gameObject
        --出售选中
        self.sellSelect = self.transform:FindChild("SellSelect").gameObject
        --选中
        self.goSelect = self.transform:FindChild("Select").gameObject

        ClickEventListener.Get(self.goIcon).onClick = self.OnClick
        ClickEventListener.Get(self.sellFlag).onClick = self.OnNotSell
        ClickEventListener.Get(self.goLock).onClick = self.OnLockClick
    end

    self.OnClick = function()
        if not BagManager.sellFlag then
            BagManager.selectPos = data.pos
            BagManager.ShowItemTips({from=ItemTipsFromType.BAG,pos=data.pos,item_data=BagManager.items[data.pos]},false)
            UIManager.GetCtrl(ViewAssets.BagUI).UpdateBagItems()
        else
            local item = itemTable.Item[data.id]
            BagManager.ShowItemTips({from=ItemTipsFromType.BAG,pos=data.pos,item_data=BagManager.items[data.pos]},false)
            if item.CanRecycle > 0 then
                UIManager.GetCtrl(ViewAssets.BagUI).OnSellBagItem({pos=data.pos})
            else
                UIManager.GetCtrl(ViewAssets.PromptUI, function(ctrl)
                    ctrl.UpdateMsg(texttable.UIText[1101039].NR)
                end)
            end
        end
    end

    self.OnNotSell = function()
        if not UIManager.GetCtrl(ViewAssets.PromptUI).isLoaded then
            UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
                ctrl.UpdateMsg(texttable.UIText[1101039].NR)
            end)
        end        
    end

    self.OnLockClick = function()
        print("OnLockClick")
        UIManager.GetCtrl(ViewAssets.BagUI).OnUnlock({pos=data.pos})
    end

    self.SetPos = function(inpos,offset)
        local vpos = Vector3.New(-286 + ((inpos - 1) % 5) * 145,offset - 80 - math.floor((inpos - 1) / 5) * 145,0)
        self.transform.anchoredPosition3D=vpos
        self.goIcon:SetActive(false)
        self.goLock:SetActive(false)
        self.goQuality:SetActive(false)
        self.sellFlag:SetActive(false)
        self.sellSelect:SetActive(false)
    end

    self.SetData = function(indata)
        data = indata
        if data.unlock < data.pos then
            self.goLock:SetActive(true)
        else
            self.goLock:SetActive(false)
        end

        local item = itemTable.Item[data.id]

        if data.id > 0 then
            self.goIcon:SetActive(true)
            self.imgIcon.overrideSprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",item.Icon))

            self.goQuality:SetActive(true)
            self.imgQuality.overrideSprite = LuaUIUtil.GetItemQuality(data.id)
            self.numberTxt.text = data.count
            if BagManager.sellFlag then
                if item.CanRecycle == 0 then
                    self.sellFlag:SetActive(true)
                else
                    self.sellFlag:SetActive(false)
                end

                if data.sell then
                    self.sellSelect:SetActive(true)
                else
                    self.sellSelect:SetActive(false)
                end
                self.goSelect:SetActive(false)
            else
                self.sellFlag:SetActive(false)
                self.sellSelect:SetActive(false)
                if data.select then
                    self.goSelect:SetActive(true)
                else
                    self.goSelect:SetActive(false)
                end
            end

        else
            self.goQuality:SetActive(false)
            self.goIcon:SetActive(false)
            self.transform:FindChild("Number").gameObject:GetComponent("TextMeshProUGUI").text = ""
            self.numberTxt.text = ""
            self.sellFlag:SetActive(false)
            self.sellSelect:SetActive(false)
            self.goSelect:SetActive(false)
        end

    end

	return self
end

return CreateBagItemUI()

