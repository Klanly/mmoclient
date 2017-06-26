-- huasong --
require "Common/basic/LuaObject"

local function CreateFactionManager()
    local self = CreateObject()
    local factionTable = require "Logic/Scheme/system_faction"
    local factionPosition = nil
    local factionInfo = {}
    
    local Create = function()
        MessageRPCManager.AddUser(self, 'FactionBeDissolved')
        MessageRPCManager.AddUser(self, 'DissolveFactionRet')
        MessageRPCManager.AddUser(self, 'KickFactionMemberRet')
        MessageRPCManager.AddUser(self, 'PlayerBeKicked')
        MessageRPCManager.AddUser(self, 'BeInvitedToFaction')
        MessageRPCManager.AddUser(self, 'ReplyFactionInviteRet')
        MessageRPCManager.AddUser(self, 'MemberLeaveFactionRet')
        MessageRPCManager.AddUser(self, 'BuyFactionOnTopRet')
        factionPosition = {}
        for k,v in pairs(factionTable.Authority) do
            factionPosition[v.Position] = v
        end
    end  
    
    self.GetPositionName = function(position)
        return factionPosition[position].PositionName
    end
    
    self.Authority = function(authType,position,showNotice)
        local auth = factionPosition[position][authType] == 1
        if showNotice and not auth then
            UIManager.ShowNotice('你没有该权限')
        end
        return auth
    end
    
    self.SelfAuthority = function(authType,showNotice)
        return self.Authority(authType,factionInfo.position,showNotice)
    end
    
    self.UpdateFactionPosition = function(position)
        factionInfo.position = position
    end
    
    self.UpdateFactionTopTime = function(topTime)
        factionInfo.topTime = topTime or 0
    end
    
    self.GetSelfPosition = function()
        return factionInfo.position
    end
    
    self.GetTopTime = function()
        return factionInfo.topTime
    end
    
    self.InFaction = function()
        return MyHeroManager.heroData.faction_id and MyHeroManager.heroData.faction_id ~= 0
    end
    
    self.DissolveFactionRet = function(data)
        if data.result ~= 0 then return end
        UIManager.UnloadView(ViewAssets.FactionUI)
        UIManager.ShowNotice('成功解散帮会')
    end
    
    self.FactionBeDissolved = function(data)
        if data.actor_id == MyHeroManager.heroData.actor_id then return end
        UIManager.UnloadView(ViewAssets.FactionUI)
        UIManager.ShowNotice('帮会已被解散')
    end
    
    self.KickFactionMemberRet = function(data)
        if data.result ~= 0 then return end
        UIManager.ShowNotice('成功踢出帮会成员')
    end
    
    self.PlayerBeKicked = function(data)
        if data.result ~= 0 then return end
        UIManager.UnloadView(ViewAssets.FactionUI)
        UIManager.ShowNotice('你已被踢出帮会')
    end
    
    self.BeInvitedToFaction = function(data)
        local Approve = function(agree)
            local sendData = {}
            sendData.func_name = 'on_reply_faction_invite'
            sendData.faction_id = data.inviter_faction_id
            sendData.is_agree = agree
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, sendData) 
        end
        UIManager.ShowDialog(string.format('<color=green>%s</color>玩家邀请你加入帮会：\n<color=yellow>%s</color>',data.inviter_name,data.inviter_faction_name), '拒绝邀请', '加入帮会', function() Approve(false) end, function() Approve(true) end)
    end
    
    self.ReplyFactionInviteRet = function(data)
        if data.faction_id and data.faction_id ~= -1 then
            UIManager.ShowNotice('成功加入帮会')
        end
    end
    
    self.MemberLeaveFactionRet = function(data)
        if data.faction_id and data.faction_id ~= -1 then
            UIManager.ShowNotice('成功脱离帮会')
            UIManager.UnloadView(ViewAssets.FactionUI)
        end
    end
     
    self.BuyFactionOnTopRet = function(data)
        if data.result ~= 0 then return end
        UIManager.ShowNotice('置顶成功')
        self.UpdateFactionTopTime(data.expire_time)
    end
    
    Create()
    return self
end

FactionManager = FactionManager or CreateFactionManager()