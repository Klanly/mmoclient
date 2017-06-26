---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
require "Logic/TeamManager"

-- 英雄是否存在并活着
local isHeroDied = function()
    local hero = SceneManager.GetEntityManager().hero
    if not hero or hero:IsDied() or hero:IsDestroy() then
        return true
    end
    return false
end
local showDieNotice = function()
    UIManager.ShowNotice('英雄已经死亡, 无法操作! ')
end

function CreateMainUITeamCtrl(view)
    local self = CreateObject()
	local sceneTable = require'Logic/Scheme/common_scene'
    local Create = function()
        self.sceneName = {}
        self.hpRect = {}
        self.flagDie = {}
        self.flagOffline = {}
        for i=1,4 do
            local item = view['teamMember'..i]
            self.hpRect[i] = item.transform:FindChild('hp'):GetComponent('RectTransform')
            self.sceneName[i] = item.transform:FindChild('sceneName').gameObject
            self.flagDie[i] = item.transform:FindChild('flagDie').gameObject
            self.flagOffline[i] = item.transform:FindChild('flagOffline').gameObject
        end
        
        self.OnTeamInfoChange()
        ClickEventListener.Get(view.btnCreateTeam).onClick = self.CreateTeam
        ClickEventListener.Get(view.btnJoinTeam).onClick = self.JoinTeam
        ClickEventListener.Get(view.myTeam).onClick = self.MyTeam
        UpdateBeat:Add(self.Update,self)
    end
    
    self.Update = function()
        if  not TeamManager.InTeam() then return end
        
        local teamInfo = TeamManager.GetTeamInfo()
        local currentSceneID = SceneManager.currentSceneId
        local currentDungeonID = nil
        for i=1,#teamInfo.members do
            local memberInfo = teamInfo.members[i]
            if memberInfo.actor_id == MyHeroManager.heroData.actor_id then
                currentSceneID = memberInfo.scene_id
                currentDungeonID = memberInfo.dungeon_id
                break
            end

        end
        for i=1,#teamInfo.members do
            local item = view['teamMember'..i]
            local memberInfo = teamInfo.members[i]
            local sameScene = memberInfo.scene_id == currentSceneID and memberInfo.dungeon_id == currentDungeonID
            if sameScene then
                local puppet = SceneManager.GetEntityManager().GetPuppet(memberInfo.actor_id)
                if puppet then
                    memberInfo.current_hp = puppet.hp
                    memberInfo.hp_max = puppet.hp_max()
                end              
            end
            self.hpRect[i].sizeDelta = Vector2.New(memberInfo.current_hp/(memberInfo.hp_max)*168,12)
            self.sceneName[i]:SetActive(not sameScene or not memberInfo.is_online)
            self.flagDie[i]:SetActive(memberInfo.current_hp <= 0)
            self.flagOffline[i]:SetActive(not memberInfo.is_online)
        end
    end
    
    local UpdateMemberUI = function(item,i)
        local teamInfo = TeamManager.GetTeamInfo()
        local memberInfo = teamInfo.members[i]
        item.transform:FindChild('name'):GetComponent('TextMeshProUGUI').text = memberInfo.actor_name
        item.transform:FindChild('level'):GetComponent('TextMeshProUGUI').text = memberInfo.level
        local bgCaption = item.transform:FindChild('bgCaption').gameObject
        bgCaption:SetActive(teamInfo.captain_id == memberInfo.actor_id)
        local bgNormal = item.transform:FindChild('bgNormal').gameObject
        bgNormal:SetActive(teamInfo.captain_id ~= memberInfo.actor_id)
        
        local icon = item.transform:FindChild('headIconBg/iconMask/imgRoleHead'):GetComponent('Image')
        icon.overrideSprite = LuaUIUtil.GetHeroIcon(memberInfo.vocation,memberInfo.sex)--memberInfo.sex)
        if memberInfo.is_online then
            if memberInfo.scene_id and sceneTable.MainScene[memberInfo.scene_id] then
                item.transform:FindChild('sceneName'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(sceneTable.MainScene[memberInfo.scene_id],'Name')
            else
                item.transform:FindChild('sceneName'):GetComponent('TextMeshProUGUI').text = '副本中'
            end
            icon.material = nil
        else
            item.transform:FindChild('sceneName'):GetComponent('TextMeshProUGUI').text = '离线'
            icon.material = UIGrayMaterial.GetUIGrayMaterial()
        end
        item.transform:FindChild('flagFollow').gameObject:SetActive(memberInfo.team_state == "follow")
        item.transform:FindChild('flagFight').gameObject:SetActive(memberInfo.team_state == "on_hook")
        --item.transform:FindChild('stateBg').gameObject:SetActive(memberInfo.team_state == "follow" or memberInfo.team_state == "on_hook")
        
        ClickEventListener.Get(item.transform:FindChild('bg').gameObject).onClick = function() self.DetailClick(i) end
        --ClickEventListener.Get(bgCaption).onClick = function() self.DetailClick(i) end
        ClickEventListener.Get(view.btnFollow).onClick = TeamManager.FollowCaptain
        ClickEventListener.Get(view.btnSummon).onClick = TeamManager.SummonMembers
        ClickEventListener.Get(view.btnCancelSummon).onClick = TeamManager.CancelSummon
        ClickEventListener.Get(view.btnCancelFollow).onClick = TeamManager.CancelFollow
        
        ClickEventListener.Get(view.btnFollow1).onClick = TeamManager.FollowCaptain
        ClickEventListener.Get(view.btnSummon1).onClick = TeamManager.SummonMembers
        ClickEventListener.Get(view.btnCancelSummon1).onClick = TeamManager.CancelSummon
        ClickEventListener.Get(view.btnCancelFollow1).onClick = TeamManager.CancelFollow
    end
    
    self.DetailClick = function(i)
        local teamInfo = TeamManager.GetTeamInfo()
        local memberInfo = teamInfo.members[i]
        UIManager.PushView(ViewAssets.TeamOpUI,nil,Vector2.New(-485,460 - 100*i),memberInfo)
    end
    
    self.OnTeamInfoChange = function()
        local teamInfo = TeamManager.GetTeamInfo()
        local noTeam = not TeamManager.InTeam()
        local showBtns = not noTeam and #teamInfo.members > 1
        local captain = TeamManager.IsCaptain()
        local follow = TeamManager.GetState() == 'follow'
        view.teamBtns:SetActive(showBtns)
        view.btnFollow:SetActive(showBtns and not captain and not follow)
        view.btnCancelFollow:SetActive(showBtns and not captain and follow)
        view.btnCancelSummon:SetActive(showBtns and captain and not TeamManager.AllFreeMove())
        view.btnSummon:SetActive(showBtns and captain and not TeamManager.AllFollow())
        
        view.btnFollow1:SetActive(showBtns and not captain and not follow)
        view.btnCancelFollow1:SetActive(showBtns and not captain and follow)
        view.btnCancelSummon1:SetActive(showBtns and captain and not TeamManager.AllFreeMove())
        view.btnSummon1:SetActive(showBtns and captain and TeamManager.AllFreeMove())
        
        view.teamFollowingState:SetActive(true)
        if showBtns and not captain and follow then
            view.teamFollowingState:GetComponent('TextMeshProUGUI').text = '跟随中。'
        elseif showBtns and captain and not TeamManager.AllFreeMove() then
            view.teamFollowingState:GetComponent('TextMeshProUGUI').text = '队员跟随中。需要解除跟随才能战斗。'
        else
            view.teamFollowingState:SetActive(false)
        end
        
        view.btnCreateTeam:SetActive(noTeam)
        view.btnJoinTeam:SetActive(noTeam)

        for i=1,4 do
            local item = view['teamMember'..i]
            item:SetActive(not noTeam and teamInfo.members[i] ~= nil)
            if not noTeam and teamInfo.members[i] ~= nil then
                UpdateMemberUI(item,i)
            end
        end
    end
    
    self.CreateTeam = function()
        if isHeroDied() then showDieNotice(); return end
        local data = {}
        data.func_name = 'on_make_team'
        data.target = 'free'
        data.auto_join = true
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.JoinTeam = function()
        if isHeroDied() then showDieNotice(); return end
        UIManager.PushView(ViewAssets.TeamApplyUI)
    end
    
    self.MyTeam = function()
        if isHeroDied() then showDieNotice(); return end
        if not TeamManager.InTeam() then return end
        UIManager.PushView(ViewAssets.TeamUI)
    end
    
	self.onUnload = function()
        UpdateBeat:Remove(self.Update,self)
	end
	
    Create()
	return self
end