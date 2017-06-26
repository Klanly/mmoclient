----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateFriendsAddUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.item = self.transform:FindChild("bgsearchresult/@item").gameObject;
		self.noResultNote = self.transform:FindChild("bgsearchresult/@noResultNote").gameObject;
		self.noneResultText = self.transform:FindChild("bgsearchresult/@noResultNote/@noneResultText").gameObject;
		self.scrollview = self.transform:FindChild("bgsearchresult/@scrollview").gameObject;
		self.inputPart = self.transform:FindChild("bgsearchresult/@inputPart").gameObject;
		self.inputField = self.transform:FindChild("bgsearchresult/@inputPart/@inputField").gameObject;
		self.btnSearch = self.transform:FindChild("bgsearchresult/@inputPart/@btnSearch").gameObject;
	end
	return self;
end
FriendsAddUI = FriendsAddUI or CreateFriendsAddUI();
