---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateTeamRankListUICtrl()
    local self = CreateCtrlBase()
    local teamDungeons = (require'Logic/Scheme/challenge_team_dungeon').TeamDungeons
    
    local UpdateTeamMember = function(item,data)
        if data == nil then item:SetActive(false) return end
        item:SetActive(true)
        item.transform:FindChild('name'):GetComponent('TextMeshProUGUI').text = data.actor_name
        item.transform:FindChild('level'):GetComponent('TextMeshProUGUI').text = string.format('通关等级：%d级',data.level)
        item.transform:FindChild('mask/icon'):GetComponent('Image').sprite = LuaUIUtil.GetHeroIcon(data.vocation,data.sex)
    end
    
    local UpdateTeamInfo = function(item,data)
        if data == nil then item:SetActive(false) return end
        item:SetActive(true)
        item.transform:FindChild('costTime'):GetComponent('TextMeshProUGUI').text = string.format('通关时间：%d分%d秒',math.floor(data.time/60),data.time%60)
        --item.transform:FindChild('mask/icon'):GetComponent('Image')
        
        local number = 1
        for i=1,4 do
            if data.members[i] and data.members[i].actor_id == data.captain_id then
                UpdateTeamMember(item.transform:FindChild('captain').gameObject,data.members[i])
            elseif item.transform:FindChild('teamMember'..number) then
                UpdateTeamMember(item.transform:FindChild('teamMember'..number).gameObject,data.members[i])
                number = number + 1
            end
        end
    end
    
    self.onLoad = function(id,data)
        if teamDungeons[id] == nil then self.close() return end
        
        self.AddClick(self.view.btnConfirm,self.close)
        self.AddClick(self.view.btnClose,self.close)
        self.view.dungeonName:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(teamDungeons[id],'Name')
        for i = 1,3 do
            UpdateTeamInfo(self.view['rank'..i],data[i])
        end
    end
	
	self.onUnload = function()
    
	end
    
	return self
end

return CreateTeamRankListUICtrl()