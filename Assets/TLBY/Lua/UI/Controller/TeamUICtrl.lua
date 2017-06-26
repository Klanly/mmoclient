---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateTeamUICtrl()
    local self = CreateCtrlBase()
    local tableData = (require'Logic/Scheme/challenge_team_dungeon').TeamDungeons
    local models = {}
    
    local UpdateMemberUI = function(item,i)
        local teamInfo = TeamManager.GetTeamInfo()
        local memberInfo = teamInfo.members[i]
        item.transform:FindChild('captainLabel').gameObject:SetActive(teamInfo.captain_id == memberInfo.actor_id)
        item.transform:FindChild('name'):GetComponent('TextMeshProUGUI').text = memberInfo.actor_name
        item.transform:FindChild('level'):GetComponent('TextMeshProUGUI').text = 'lv:'..memberInfo.level
        item.transform:FindChild('occupation'):GetComponent('TextMeshProUGUI').text = "职业："..LuaUIUtil.getVocationName(memberInfo.vocation)
        --item.transform:FindChild('icon'):GetComponent('Image').overrideSprite = LuaUIUtil.GetHeroIcon(memberInfo.vocation,memberInfo.sex)
        local modelPos = item.transform:FindChild('model')

        local SetModel = function(go)
            if models[i] ~= nil then
                RecycleObject(models[i])
                models[i] = nil
            end
            if not self.isLoaded then
                RecycleObject(go)
                return
            end
            models[i] = go
            models[i].transform:SetParent(modelPos,false)
            models[i].transform.localPosition = Vector3.zero
            models[i].transform.localScale = Vector3.one
            models[i].transform.localEulerAngles = Vector3.zero
        end
        LuaUIUtil.GetHeroModel(memberInfo.vocation,memberInfo.sex,SetModel)

        --item.transform:FindChild('icon1').gameObject:SetActive(memberInfo.sex ~= 1)
        self.AddClick(item.transform:FindChild('bg').gameObject, function() self.DetailClick(i) end)
    end
    
	self.onLoad = function()
        self.AddClick(self.view.btnLeave, TeamManager.SendLeaveTeam)
        self.AddClick(self.view.btnEnter, function() self.close() TeamManager.EnterDungeonRequest() end)
        self.AddClick(self.view.targetLabel, self.OpenTargetChangeUI)
        self.AddClick(self.view.btnClose, self.close)
        self.AddClick(self.view.btnRecruitFriends,self.RecruitFriends)
        ClickEventListener.Get(self.view.btnFollow).onClick = TeamManager.FollowCaptain
        ClickEventListener.Get(self.view.btnSummon).onClick = TeamManager.SummonMembers
        ClickEventListener.Get(self.view.btnCancelSummon).onClick = TeamManager.CancelSummon
        ClickEventListener.Get(self.view.btnCancelFollow).onClick = TeamManager.CancelFollow
        self.AddClick(self.view.autoAgreeToggle,self.AutoJoin)
        
        self.OnTeamInfoChange()
	end
    
    self.HideModel = function()
        for k,v in pairs(models) do
            RecycleObject(v)
        end
        models = {}
    end
	
	self.onUnload = function()
        self.HideModel()
	end
    
    self.RecruitFriends = function()
        ContactManager.ClearList()
        ContactManager.PushView(ViewAssets.TeamInviteUI)
    end
    
    self.OpenTargetChangeUI = function()
        if not TeamManager.IsCaptain() then UIManager.ShowNotice('只有队长有权限进行此操作') return end
        UIManager.PushView(ViewAssets.TeamChangeTargetUI)
    end
	
    self.AutoJoin = function()
        if not TeamManager.IsCaptain() then UIManager.ShowNotice('只有队长有权限进行此操作') return end
        
        local teamInfo = TeamManager.GetTeamInfo()
        if self.view.autoAgreeToggle:GetComponent('Toggle').isOn ~= teamInfo.auto_join then
            self.view.autoAgreeToggle:GetComponent('Toggle').isOn = teamInfo.auto_join
            return
        end
        
        local data = {}
        data.func_name = 'on_set_auto_join'
        data.auto_join = not self.view.autoAgreeToggle:GetComponent('Toggle').isOn
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)  
    end
    
    self.DetailClick = function(i)
        local teamInfo = TeamManager.GetTeamInfo()
        local memberInfo = teamInfo.members[i]
        if memberInfo.actor_id == MyHeroManager.heroData.actor_id then return end
        UIManager.PushView(ViewAssets.TeamOpUI,nil,Vector2.New(self.view['player'..i]:GetComponent('RectTransform').anchoredPosition.x,240),memberInfo)
    end
    
    self.OnTeamInfoChange = function()
        if not TeamManager.InTeam() then self.close() return end
        
        local teamInfo = TeamManager.GetTeamInfo()
        if tableData[teamInfo.target] ~= nil then
            self.view.targetDes:GetComponent('TextMeshProUGUI').text = string.format('%s(%d-%d级)',LuaUIUtil.GetTextByID(tableData[teamInfo.target],'Name'),teamInfo.min_level,teamInfo.max_level)
        else
            self.view.targetDes:GetComponent('TextMeshProUGUI').text = string.format('%s(%d-%d级)','自由组队',teamInfo.min_level,teamInfo.max_level)
        end
        self.view.autoAgreeToggle:GetComponent('Toggle').isOn = teamInfo.auto_join
        for i=1,4 do
            local item = self.view['player'..i]
            item:SetActive(teamInfo.members[i] ~= nil)
            self.view['btnadd'..i]:SetActive(teamInfo.members[i] == nil)
            self.AddClick(self.view['btnadd'..i].transform:FindChild('btn').gameObject,self.RecruitFriends)
            if teamInfo.members[i] ~= nil then
                UpdateMemberUI(item,i)
            end
        end

        local showBtns = #teamInfo.members > 1
        local captain = TeamManager.IsCaptain()
        local follow = TeamManager.GetState() == 'follow'
        self.view.btnFollow:SetActive(showBtns and not captain and not follow)
        self.view.btnCancelFollow:SetActive(showBtns and not captain and follow)
        self.view.btnCancelSummon:SetActive(showBtns and captain and not TeamManager.AllFreeMove())
        self.view.btnSummon:SetActive(showBtns and captain and not TeamManager.AllFollow())
    end
    
	return self
end

return CreateTeamUICtrl()