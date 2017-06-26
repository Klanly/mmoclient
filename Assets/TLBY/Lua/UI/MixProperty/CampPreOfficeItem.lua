-- auth： zhangzeng
-- date： 2017/6/5
require "UI/View/LuaViewBase"

local function CreateCampPreOfficeItem()
	local self = CreateViewBase()
	self.data = nil
	
	self.Awake = function()
		self.textname = self.transform:FindChild("textname").gameObject;
		self.textoffice = self.transform:FindChild("textoffice").gameObject;
		self.texttickets = self.transform:FindChild("texttickets").gameObject;
		self.textlike = self.transform:FindChild("textlike").gameObject;
		self.btnlike = self.transform:FindChild("btnlike").gameObject;
	end
	
	self.OnDestroy = function()
		MessageRPCManager.RemoveUser(self, 'GiveLikeToHistoryOfficerRet')
	end

	self.GiveLikeToHistoryOfficerRet = function(data) --历史官员点赞反馈
	--[[
		local historyOfficers = data.history_officers
		if historyOfficers == nil then
			return
		end
		
		for k, v in pairs(historyOfficers) do
			local like = historyOfficers[k].like
			if like == nil then
				like = 0
			end
			self.textlike:GetComponent('TextMeshProUGUI').text = '点赞数：'.. like
		end
		]]
	end

	self.SetData = function(data)
		self.data = data
	end
	
	self.OnLike = function()
		local data = {}
		data.func_name = 'on_give_like_to_history_officer'
		data.index = self.data.index
		data.officer_id = self.data.actor_id
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.Init = function()
		ClickEventListener.Get(self.btnlike).onClick = self.OnLike --点赞
		MessageRPCManager.AddUser(self, 'GiveLikeToHistoryOfficerRet')
	end

	return self
end

return CreateCampPreOfficeItem()
