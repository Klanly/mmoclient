---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateTeamConfirmUICtrl()
    local self = CreateCtrlBase()
    local tableData = (require'Logic/Scheme/challenge_team_dungeon').TeamDungeons
    local uiText = GetConfig('common_char_chinese').UIText
    local sureID = nil
    local timer = nil
    local target = nil
    local second = 30
    local confirmedIDs = {}
    self.layer = LayerGroup.popCanvas
    
    self.onLoad = function(_target,sure_id,showAwardNote)
        sureID = nil
        if not TeamManager.IsCaptain() then
            sureID = sure_id
        end
        target = _target
        confirmedIDs = {}
        confirmedIDs[TeamManager.GetTeamInfo().captain_id] = true
        
        self.AddClick(self.view.btnClose ,self.close)
        self.AddClick(self.view.btnCancel ,self.close)
        self.AddClick(self.view.btnAgree ,self.Agree)
        MessageRPCManager.AddUser(self, 'TeamMemberReplyEnterDungeon')
        
        UIUtil.Vibrate()
        self.view.targetName:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(tableData[target],'Name')
        self.view.btnAgree:SetActive(sureID ~= nil)
        self.view.btnCancel:SetActive(sureID ~= nil)
        self.view.awardNote:SetActive(not showAwardNote)
        self.UpdateTeamInfo()
        second = 10
        self.CountDown()
        if timer then Timer.Romve(timer) end  
        timer = Timer.Repeat(1,self.CountDown)
    end
	
	self.onUnload = function()
        if sureID then
            local data = {}
            data.func_name = 'on_ensure_enter_dungeon'
            data.sure_sign = -1
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        end
        MessageRPCManager.RemoveUser(self, 'TeamMemberReplyEnterDungeon')
        if timer then Timer.Remove(timer) end  
        timer = nil
	end
    
    self.CountDown = function()
        self.view.timer:GetComponent('TextMeshProUGUI').text = second..'秒后自动拒绝'
        second = second - 1
        if second < 0 then
            self.close()
        end
    end
    
    self.UpdateTeamInfo = function()
        local num = 1
        for _,data in pairs(TeamManager.GetTeamInfo().members) do
            local item = self.view['item'..num]
            item:SetActive(true)
            item.transform:Find('mask/icon'):GetComponent('Image').overrideSprite = LuaUIUtil.GetHeroIcon(data.vocation,data.sex)
            item.transform:Find('level'):GetComponent('TextMeshProUGUI').text = data.level
            item.transform:Find('name'):GetComponent('TextMeshProUGUI').text = data.actor_name
            item.transform:Find('rotate').gameObject:SetActive(confirmedIDs[data.actor_id] ~= true)
            item.transform:Find('confirmed').gameObject:SetActive(confirmedIDs[data.actor_id] == true)
            num = num + 1
        end
        for i=num,4 do
            self.view['item'..i]:SetActive(false)
        end
    end
    
    self.Agree = function()
        local data = {}
        data.func_name = 'on_ensure_enter_dungeon'
        data.sure_sign = sureID
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        sureID = nil
        self.view.btnAgree:SetActive(sureID ~= nil)
        self.view.btnCancel:SetActive(sureID ~= nil)
        confirmedIDs[MyHeroManager.heroData.actor_id] = true
        self.UpdateTeamInfo()
    end
    
    self.TeamMemberReplyEnterDungeon = function(data)
        if data.sure_sign == -1 then
            showBtns = false
            sureID = nil
            self.close()
        else
            confirmedIDs[data.member_id] = true
            self.UpdateTeamInfo()
        end
    end
    
	return self
end

return CreateTeamConfirmUICtrl()