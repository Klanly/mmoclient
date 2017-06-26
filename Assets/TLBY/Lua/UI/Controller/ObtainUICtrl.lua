--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/11 0011
-- Time: 17:58
-- To change this template use File | Settings | File Templates.
--
require "UI/Controller/LuaCtrlBase"

local texttable = require "Logic/Scheme/common_char_chinese"

local function CreateObtainUICtrl()
    local self = CreateCtrlBase()
    local items = {}

    local function CreateHuntDetailItemUI(template, data)
        local self = CreateScrollviewItem(template)
        self.transform:Find("Icon"):GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(data.id)
        self.transform:Find("Quality"):GetComponent('Image').overrideSprite = LuaUIUtil.GetItemQuality(data.id)
        self.transform:Find("textNumber"):GetComponent('TextMeshProUGUI').text = data.count
        ClickEventListener.Get(self.transform:FindChild('Icon').gameObject).onClick = function()
            BagManager.ShowItemTips({item_data={id=data.id}},true)
        end
        return self
    end

    local function clearHuntDetailItem(self)
        for k, v in ipairs(items) do
            DestroyScrollviewItem(v)
        end
        items = {}
    end

    self.onLoad = function()
        ClickEventListener.Get(self.view.Mask).onClick = self.close
        ClickEventListener.Get(self.view.CloseBtn).onClick = self.close
    end

    self.UpdateData = function(data)
        clearHuntDetailItem()
        for k,v in pairs(data) do
            local tmp = CreateHuntDetailItemUI(self.view.ObtainItem, {id=k,count=v})
            table.insert(items, tmp)
        end
        local width = #items * 180
        if width < 950 then
            width = 950
        end
        self.view.Content:GetComponent("RectTransform").sizeDelta = Vector2.New(width,160)
    end

    self.onUnload = function()
        clearHuntDetailItem()
        items = {}
    end

    return self
end

return CreateObtainUICtrl()

