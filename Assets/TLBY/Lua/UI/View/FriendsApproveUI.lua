----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateFriendsApproveUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.item = self.transform:FindChild("@item").gameObject;
		self.scrollview = self.transform:FindChild("@scrollview").gameObject;
		self.btnApprove = self.transform:FindChild("bottom/@btnApprove").gameObject;
		self.btnRefuse = self.transform:FindChild("bottom/@btnRefuse").gameObject;
	end
	return self;
end
FriendsApproveUI = FriendsApproveUI or CreateFriendsApproveUI();
