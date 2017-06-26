require "UI/Controller/LuaCtrlBase"

local function CreateFactionPositionUICtrl()
	local self = CreateCtrlBase()
    local items = {}
    local id = nil
    local factionTable = (require "Logic/Scheme/system_faction").Authority
    
    local IntToPosition = 
    {
        [10] = function() UIManager.ShowNotice('权限不足') return false end,
        [20] = function() return FactionManager.SelfAuthority('Deputy',true) end,
        [30] = function() return FactionManager.SelfAuthority('Dhammapala',true) end,
        [40] = function() return FactionManager.SelfAuthority('Elder',true) end,
        [50] = function() return FactionManager.SelfAuthority('Starflex',true) end,
        [60] = function() return FactionManager.SelfAuthority('Elite',true) end,
        [70] = function() return FactionManager.SelfAuthority('Member',true) end,
    }
    
    local SetPosition = function(position)  
        if not IntToPosition[position]() then 
            return
        end
        local data = {}
        data.func_name = 'on_change_position'
        data.member_id = id
        data.position = position
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        self.close()
    end
    
	self.onLoad = function(position,member_id)
        id = member_id
        for k,v in pairs(factionTable) do
            if v.Position ~= position and v.Position ~= constant.FACTION_POSITION_NAME_TO_INDEX.chief then
                local clone = GameObject.Instantiate(self.view.item) 
                table.insert(items,clone)
                clone:SetActive(true)
                clone.transform:SetParent(self.view.grid.transform,false)
                clone.transform:Find('btn/text'):GetComponent('TextMeshProUGUI').text = v.PositionName
                self.AddClick(clone.transform:Find('btn').gameObject, function() SetPosition(v.Position) end)
            end
        end
        self.view.item:SetActive(false)
        self.AddClick(self.view.btnClose,self.close)
	end
    
    self.onUnload = function()
        for i =#items,1,-1 do
            GameObject.Destroy(items[i])
        end
        items = {}
	end

	return self
end

return CreateFactionPositionUICtrl()
