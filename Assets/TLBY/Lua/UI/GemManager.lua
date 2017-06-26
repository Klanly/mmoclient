local function CreateGemManager()
    local self = CreateObject()
    self.gemInfo = nil

    self.UpdateData = function(data)
        if data.login_data and data.login_data.equipment_gem then
            self.gemInfo = data.login_data.equipment_gem
            UIManager.GetCtrl(ViewAssets.EquipGemUI).UpdateSlot()
        elseif data.equipment_gem then
            self.gemInfo = data.equipment_gem
            UIManager.GetCtrl(ViewAssets.EquipGemUI).UpdateSlot()
        end
    end
    
    self.GemNoticeHandler = function(data)
        if data.result ~= 0 then
            UIManager.ShowErrorMessage(data.result)
            return
        end
    end
    
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_UPDATE, self.UpdateData)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_LOGIN, self.UpdateData)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GEM_INLAY, self.GemNoticeHandler)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GEM_OPEN_SLOT, self.GemNoticeHandler)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GEM_COMBINE, self.GemNoticeHandler)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GEM_CARVE, self.GemNoticeHandler)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GEM_IDENTIFY , self.GemNoticeHandler)
    return self
end

GemManager = GemManager or CreateGemManager()