--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/20 0020
-- Time: 15:58
-- To change this template use File | Settings | File Templates.
--

require "UI/Controller/LuaCtrlBase"

local texttable = require "Logic/Scheme/common_char_chinese"
local itemtable = require "Logic/Scheme/common_item"
local localization = require "Common/basic/Localization"

local uitext = texttable.UIText
local itemconfigs = itemtable.Item

local function CreatePurchaseUICtrl()
    local self = CreateCtrlBase()
    --self.layer = LayerGroup.popCanvas
    local data = {}
    self.selectId = 0
    local items = {}

    local function Close()
        if data.cancelHandler ~= nil then
            data.cancelHandler()
        end
        self.close()
    end

    local function OnCloseBtnClick()
        Close()
    end

    local function OnOkBtnClick()
        if data.okHandler ~= nil then
            data.okHandler(self.selectId)
        end
        Close()
    end

    local function OnPurchaseBtnClick()
        UIManager.GetCtrl(ViewAssets.MallUI).OpenUI(self.selectId)
--        UIManager.PushView(ViewAssets.PromptUI)
--        UIManager.GetCtrl(ViewAssets.PromptUI).UpdateMsg(texttable.UIText[1101040].NR)
    end

    self.onLoad = function()
        --确定按钮
        self.textOKBtn = self.view.textok:GetComponent("TextMeshProUGUI")
        --self.textOKBtn.fontSize = 40
        --UIUtil.SetTextAlignment(self.textOKBtn,TextAnchor.MiddleCenter)
        --UIUtil.AddTextOutline(self.view.textok,Color.New(255/255,222/255,191/255))
        self.textOKBtn.text = uitext[1101006].NR
        --购买按钮
        self.textPurchaseBtn = self.view.textbuy:GetComponent("TextMeshProUGUI")
        --self.textPurchaseBtn.fontSize = 40
        --UIUtil.SetTextAlignment(self.textPurchaseBtn,TextAnchor.MiddleCenter)
        --UIUtil.AddTextOutline(self.view.textbuy,Color.New(255/255,222/255,191/255))
        self.textPurchaseBtn.text = uitext[1115015].NR

        --抬头
        self.textTitle = self.view.textchoosepropstitle:GetComponent("TextMeshProUGUI")
        --self.textTitle.fontSize = 40
        --UIUtil.SetTextAlignment(self.textTitle,TextAnchor.MiddleCenter)
        --物品名称
        self.textName = self.view.textpropstitle:GetComponent("TextMeshProUGUI")
        --self.textName.fontSize = 26
        --UIUtil.SetTextAlignment(self.textName,TextAnchor.MiddleCenter)
        --物品描述
        self.textDescription = self.view.textprop:GetComponent("TextMeshProUGUI")
        --self.textDescription.fontSize = 26
        --UIUtil.SetTextAlignment(self.textDescription,TextAnchor.MiddleLeft)

        self.scrollViewContentTransform = self.view.Content:GetComponent("RectTransform")

        ClickEventListener.Get(self.view.btnNormal).onClick = OnPurchaseBtnClick
        ClickEventListener.Get(self.view.btnNormal2).onClick = OnOkBtnClick
        ClickEventListener.Get(self.view.btnclose).onClick = OnCloseBtnClick
    end

    --data
    --items={1001,1002}物品id列表
    --okHandler选择之后处理函数
    --cancelHandler取消之后处理
    --title 抬头
    self.UpdateData = function(indata)
        data = indata
        self.selectId = 0
        self.UpdateView()
    end

    local function SetItemPosition(total_count,current_count)
        if total_count < 6 then
            self.scrollViewContentTransform.sizeDelta = Vector2.New(1100,0)
        else
            self.scrollViewContentTransform.sizeDelta = Vector2.New(180*total_count + 100)
        end

        local yPosition = 0
        if total_count == 1 then
            items[current_count].transform.anchoredPosition3D = Vector3.New(0,yPosition,0)
        elseif total_count == 2 then
            items[current_count].transform.anchoredPosition3D = Vector3.New(current_count*300-450,yPosition,0)
        elseif total_count == 3 then
            items[current_count].transform.anchoredPosition3D = Vector3.New(current_count*280-560,yPosition,0)
        elseif total_count == 4 then
            items[current_count].transform.anchoredPosition3D = Vector3.New(current_count*260-650,yPosition,0)
        elseif total_count == 5 then
            items[current_count].transform.anchoredPosition3D = Vector3.New(current_count*220-660,yPosition,0)
        else
            local xPosition = -90*total_count - 50
            items[current_count].transform.anchoredPosition3D = Vector3.New(xPosition + current_count*180,yPosition,0)
        end
        items[current_count].obj:SetActive(true)
    end

    self.UpdateView = function()
        local itemcount = #data.items
        if itemcount == 0 then
            Close()
            return
        end
        if self.selectId == 0 then
            self.selectId = data.items[1]
        end
        for i=1,itemcount,1 do
            if not items[i] then
                local current_itemcount = i
                local vv= data.items[i]
                 ResourceManager.CreateUI("PurchaseItemUI/PurchaseItemUI",function(obj)
                     items[current_itemcount] = {}
                     items[current_itemcount].obj = obj
                     items[current_itemcount].transform = items[current_itemcount].obj:GetComponent("RectTransform")
                     items[current_itemcount].transform:SetParent(self.scrollViewContentTransform,false)
                     items[current_itemcount].table = items[current_itemcount].obj:GetComponent("LuaBehaviour").luaTable
                     items[current_itemcount].table.SetData(vv)
                     SetItemPosition(itemcount,current_itemcount)
                 end)
            else
                items[i].table.SetData(data.items[i])
                SetItemPosition(itemcount,i)
            end
        end

        for k,v in pairs(items) do
            if k > itemcount and items[k].obj then
                items[k].obj:SetActive(false)
            end
        end

        local select_config = itemconfigs[self.selectId]
        if select_config then
            self.textName.text = localization.GetItemName(select_config.ID)
            self.textDescription.text = localization.GetItemDescription(select_config.ID)
        else
            self.textName.text = ""
            self.textDescription.text = ""
        end

        if data.title ~= nil then
            self.textTitle.text = data.title
        end
    end

    self.onUnload = function()
        for i,v in pairs(items) do
            RecycleObject(v.obj)
        end
        self.selectId = 0
        items = {}
    end

    return self
end

return CreatePurchaseUICtrl()

