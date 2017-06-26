--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/11/2 0002
-- Time: 16:30
-- To change this template use File | Settings | File Templates.
--

require "UI/Controller/LuaCtrlBase"

local function CreatePropertyChangeUICtrl()
    local self = CreateCtrlBase()
    self.layer = LayerGroup.popCanvas
    local items = {}
    local closeTimer = nil

    local function Close()
        UIManager.UnloadView(ViewAssets.PropertyChangeUI)
    end

    local function OnMaskClick()
        Close()
    end

    self.onLoad = function(data)
        self.bgTransform = self.view.bgtips2:GetComponent("RectTransform")
        self.scrollViewTransform = self.view.ScrollView:GetComponent("RectTransform")
        self.contentTransform = self.view.Content:GetComponent("RectTransform")

        ClickEventListener.Get(self.view.mask).onClick = OnMaskClick
        if data ~= nil then
            self.UpdateData(data)
        end
    end

    --data = {i={property,number1,number2}}
    self.UpdateData = function(data)
        local total = #data
        local count = 1
        local yPosition = 44
        for i = 0,total,1 do
            if items[count] == nil or items[count].obj == nil then
                local current_count = count
                local current_yPosition = yPosition
                ResourceManager.CreateUI("AutoGenerate/PropertyChangeItemUI",function(obj)
                    items[current_count] = {}
                    items[current_count].obj = obj
                    items[current_count].transform = items[current_count].obj:GetComponent("RectTransform")
                    items[current_count].table = items[current_count].obj:GetComponent("LuaBehaviour").luaTable
                    items[current_count].transform:SetParent(self.contentTransform,false)
                    items[current_count].transform.anchoredPosition3D = Vector3.New(0,-current_yPosition,0)
                    items[current_count].table.SetData(data[i].property,data[i].number1,data[i].number2,true)
                end)
            else
                items[count].transform:SetParent(self.contentTransform,false)
                items[count].transform.anchoredPosition3D = Vector3.New(0,-yPosition,0)
                items[count].table.SetData(data[i].property,data[i].number1,data[i].number2,true)
            end
            yPosition = yPosition + 65
            count = count + 1
        end
        local bgHeight = 1054
        if yPosition < bgHeight then
            bgHeight = yPosition
        end
        self.bgTransform.sizeDelta = Vector2.New(self.bgTransform.sizeDelta.x,bgHeight)
        self.scrollViewTransform.sizeDelta = Vector2.New(self.scrollViewTransform.sizeDelta.x,bgHeight)
        self.contentTransform.sizeDelta = Vector2.New(self.contentTransform.sizeDelta.x,yPosition - 10)
        self.RemoveTimer()
        closeTimer = Timer.Delay(5,function()
            Close()
            self.RemoveTimer()
        end)
    end

    self.RemoveTimer = function()
        if closeTimer then
            Timer.Remove(closeTimer)
        end
        closeTimer = nil
    end

    self.onUnload = function()
        for i,v in pairs(items) do
            v.transform:SetParent(nil)
            RecycleObject(v.obj)
        end
        items = {}
        self.RemoveTimer()
    end

    return self
end

return CreatePropertyChangeUICtrl()