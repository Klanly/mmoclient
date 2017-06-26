---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/1
-- desc： 
---------------------------------------------------

require "UI/Controller/LuaCtrlBase"
local floor = math.floor

local function CreateDialogueUICtrl()
	local self = CreateCtrlBase()
    self.layer = LayerGroup.popCanvas
    
    local timeDataList = {}
    local normalDataList = {}
    
    self.PushDialog = function(des, okText, cancelText, onOKCallback, onCancelCallback,defaultOperation,defaultDelay)
        local data = {}
        data.des = des
        data.okText = okText
        data.cancelText = cancelText
        data.onOKCallback = onOKCallback
        data.onCancelCallback = onCancelCallback

        if defaultDelay and defaultOperation then
            data.defaultOperation = defaultOperation
            data.defaultDelay = defaultDelay
            table.insert(timeDataList,data)
            table.sort(timeDataList,function(a,b) return a.defaultDelay<b.defaultDelay end)
        else
            table.insert(normalDataList,data)
        end
        
        if not self.isLoaded then
            UIManager.PushView(ViewAssets.DialogueUI,self.UpdateUI)
        else
            self.UpdateUI()
        end
    end
    
    self.UpdateUI = function()
        local data = nil
        if #timeDataList > 0 then
            data = timeDataList[1]
        elseif #normalDataList > 0 then
            data = normalDataList[1]
        end
        if not data then
            self.close()
            return
        end
        self.AddClick(self.view.btnok,function()
        	if data.onOKCallback then
        		data.onOKCallback()
        	end
            self.DelectData()
            end)
        self.AddClick(self.view.btncancel,function()
        	if data.onCancelCallback then
        		data.onCancelCallback()
        	end
        	self.DelectData()
            end)
        self.view.text:GetComponent('TextMeshProUGUI').text = data.des
        self.textok.text = data.okText or '确定'
        self.textcancel.text = data.cancelText or '取消'
        self.UpdateTimerUI()
    end
    
    self.DelectData = function()
        if #timeDataList > 0 then
            table.remove(timeDataList,1)
        elseif #normalDataList > 0 then
            table.remove(normalDataList,1)
        end
        self.UpdateUI()
    end
    
    self.UpdateTimerUI = function()
        local data = timeDataList[1]
        if data then
            if data.defaultOperation == "ok" then
                self.textok.text = (okText or '确定')..'('..data.defaultDelay..')'
            elseif data.defaultOperation == "cancel" then
                self.textcancel.text = (cancelText or '取消')..'('..data.defaultDelay..')'
            end
        end
    end
    
    self.UpdateTimerInfo = function()
        if #timeDataList >0 then
           for i=1,#timeDataList do
                local data = timeDataList[i]
                data.defaultDelay = data.defaultDelay -1
                if data.defaultDelay <= 0 then
                    if data.defaultOperation == "ok" then
                        if data.onOKCallback then
							data.onOKCallback()
						end
                    elseif data.defaultOperation == "cancel" then
                        if data.onCancelCallback then
                            data.onCancelCallback()
                        end
                    end
                    self.DelectData()
                end
           end
           self.UpdateTimerUI()
        end
    end
    
	self.defaultTimer = nil
	self.onLoad = function()
        self.defaultTimer = Timer.Repeat(1,self.UpdateTimerInfo)
        self.textok = self.view.textok:GetComponent('TextMeshProUGUI')
        self.textcancel = self.view.textcancel:GetComponent('TextMeshProUGUI')
	end
	
	self.onUnload = function()
		self.removeDefaultTimer()
        timeDataList = {}
        normalDataList = {}
	end

	self.removeDefaultTimer = function()
		if self.defaultTimer ~= nil then
			Timer.Remove(self.defaultTimer)
			self.defaultTimer = nil
		end
	end
	
	return self
end

return CreateDialogueUICtrl()
