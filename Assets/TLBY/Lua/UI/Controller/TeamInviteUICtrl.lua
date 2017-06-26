---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateTeamInviteUICtrl()
    local self = CreateCtrlBase()
    self.layer = LayerGroup.popCanvas
    
    local playerDatas = {}
    local invitedIds = {}
    
    local BindData = function(item,index)
        local data = playerDatas[index+1]
        item.transform:Find('mask/icon'):GetComponent('Image').overrideSprite = LuaUIUtil.GetHeroIcon(data.vocation,data.sex)
        item.transform:Find('name'):GetComponent('TextMeshProUGUI').text = data.name
        item.transform:Find('level'):GetComponent('TextMeshProUGUI').text = data.level .. '级'
        item.transform:Find('vocation'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.getVocationName(data.vocation)
        local btnInvite = item.transform:Find('btnInvite').gameObject
        if invitedIds[data.actor_id] then
            self.AddClick(btnInvite,nil)
            btnInvite:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
        else
            self.AddClick(btnInvite,function() btnInvite:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial() self.AddClick(btnInvite,nil) self.Invite(data.actor_id) end)
            btnInvite:GetComponent('Image').material = nil
        end
        
    end
    
    self.UpdateFriendsList = function()
        playerDatas = {}
        local friends = ContactManager.GetContactList('friends')
        for _,v in pairs(friends) do
            if v.offlinetime == 0 and not TeamManager.InTeam(v.actor_id) then
                local data = {}
                data.level = v.level
                data.sex = v.sex
                data.vocation = v.vocation
                data.name = v.actor_name
                data.actor_id = v.actor_id
                table.insert(playerDatas,data)
            end
        end 
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#playerDatas,BindData)
    end
    
    
    self.UpdateNearbyList = function()
        local selectNearbyPlayer = function(puppet)
            if puppet.entityType == EntityType.Dummy and puppet.data.country == MyHeroManager.heroData.country then
                return true
            end
            return false
        end 
        playerDatas = {}
        local players = SceneManager.GetEntityManager().QueryPuppets(selectNearbyPlayer)
        for _,v in pairs(players) do
            if not TeamManager.InTeam(v.data.actor_id)  then
                local data = {}
                data.level = v.data.level
                data.sex = v.data.sex
                data.vocation = v.data.vocation
                data.name = v.data.actor_name
                data.actor_id = v.data.actor_id
                table.insert(playerDatas,data)
            end
        end 
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#playerDatas,BindData)
    end
    
    self.onLoad = function()
        self.view.playerItem:SetActive(false)
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.playerItem,740,145,0,7,1)
        self.AddClick(self.view.tabFriend,self.FriendClick)
        self.AddClick(self.view.tabNearby,self.NearbyClick)
        self.AddClick(self.view.btnClose,self.close)
        invitedIds = {}
        self.FriendClick()
    end
	
	self.onUnload = function()
    
	end
    
    self.FriendClick = function()
        self.view.tabFriend:GetComponent('Toggle').isOn = true
        self.UpdateFriendsList()
    end
    
    self.NearbyClick = function()
        self.view.tabNearby:GetComponent('Toggle').isOn = true
        self.UpdateNearbyList()
    end
    
    self.Invite = function(id)
        invitedIds[id] = true
        if TeamManager.InTeam(id) then
            return
        end
        local data = {}
        data.func_name = 'on_team_invite_player'
        data.invite_player_id = id
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data) 
    end
    
	return self
end

return CreateTeamInviteUICtrl()