require "UI/Controller/LuaCtrlBase"

local function CreateTopNoticeUICtrl()
    local self = CreateCtrlBase() 
    self.layer = LayerGroup.popCanvas
    local notices = {}
    
    self.onLoad = function()
        self.view.noticeItem:SetActive(false)
        notices = {}
    end
    
    self.onUnload = function()
        for i=1,#notices do
            local data = notices[i]
            if data.time then
                Timer.Remove(data.time)
            end
            GameObject.Destroy(data.obj)
        end
        notices = {}
    end
    
    local UpdateUI = function()
        local index = 0
        for i=1,#notices do
            if not notices[i].move then
                notices[i].obj:GetComponent('RectTransform').anchoredPosition = Vector2.New(0,350+index*50)
                index = index + 1
            end
        end
    end

    self.AddNotice = function(text)
        local data = {}
        data.obj = GameObject.Instantiate(self.view.noticeItem)
        data.obj:SetActive(true)
        data.obj.transform:SetParent(self.view.pos.transform,false)
        data.obj.transform:FindChild('bg/text'):GetComponent('TextMeshProUGUI').text = text
        data.move = false
        local DelayDestroy = function()
            data.time = nil
            GameObject.Destroy(data.obj)
            table.remove(notices,#notices)
        end
        data.time = Timer.Delay(3, DelayDestroy)
        table.insert(notices,1,data)
        
        UpdateUI()
    end

    return self
end

return CreateTopNoticeUICtrl()


