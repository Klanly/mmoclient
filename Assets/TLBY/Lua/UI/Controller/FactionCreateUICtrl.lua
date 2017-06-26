require "UI/Controller/LuaCtrlBase"

local function CreateFactionCreateUICtrl()
	local self = CreateCtrlBase()
    local factionParam = (require "Logic/Scheme/system_faction").Parameter
    self.resourceBar = {}
	
	local OnClose = function()
		UIManager.UnloadView(ViewAssets.FactionCreateUI)
	end
    
	self.onLoad = function(data)
        self.AddClick(self.view.btnCreate, self.CreateFaction)
		ClickEventListener.Get(self.view.btnClose).onClick = OnClose
        MessageRPCManager.AddUser(self, 'CreateFactionRet')
        self.view.requireMoney:GetComponent('TextMeshProUGUI').text = LuaUIUtil.FormatCostText(factionParam[16].Value,BagManager.GetIngot())
	end
    
    self.onUnload = function()
        MessageRPCManager.RemoveUser(self, 'CreateFactionRet')
	end
    
    self.CreateFactionRet =function(data)
        if data.result == 0 then
            UIManager.LoadView(ViewAssets.FactionUI)
            OnClose()
        end
    end
    
    self.CreateFaction = function()
        if MyHeroManager.heroData.level < factionParam[15].Value then
            UIManager.ShowNotice('创建帮会等级不足')
            return
        end
        if not BagManager.CheckItemIsEnough({{constant.RESOURCE_NAME_TO_ID.ingot,factionParam[16].Value}}) then
            return
        end
        local name = self.view.factionName:GetComponent('TMP_InputField').text
        if string.match(name,'%d') or string.match(name,'%s') or string.match(name,'%p') then
            UIManager.ShowNotice('帮会名称只能由汉字或者字母组成')
            return
        end
        if string.utf8len(name) < 4 then
            UIManager.ShowNotice(string.format('帮会名称不得少于%d个字',4))
            return
        end
        if string.utf8len(name) > 8 then
            UIManager.ShowNotice(string.format('帮会名称不得多于%d个字',8))
            return
        end
        local des = self.view.factionAnnounce:GetComponent('TMP_InputField').text
        if string.utf8len(des) < 8 then
            UIManager.ShowNotice(string.format('请输入最少%d个汉字的帮会宣言',8))
            return
        end
        if string.utf8len(des) > factionParam[7].Value then
            UIManager.ShowNotice(string.format('当前宣言过长，不得超过%d个字',factionParam[7].Value))
            return
        end
        local data = {}
        data.func_name = 'on_create_faction'
        data.faction_name = name
        data.declaration = des
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
	return self
end

return CreateFactionCreateUICtrl()
