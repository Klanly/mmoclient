----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateOverlordlist()
	local self = CreateViewBase();
	self.Awake = function()
		self.overlordlistui = self.transform:FindChild("@overlordlistui").gameObject;
		self.titleoverlord = self.transform:FindChild("@overlordlistui/@titleoverlord").gameObject;
		self.textchapter = self.transform:FindChild("@overlordlistui/@textchapter").gameObject;
		self.txtresettime = self.transform:FindChild("@overlordlistui/@txtresettime").gameObject;
		self.btnok = self.transform:FindChild("@overlordlistui/@btnok").gameObject;
		self.textdok = self.transform:FindChild("@overlordlistui/@textdok").gameObject;
		self.btnclose = self.transform:FindChild("@overlordlistui/@btnclose").gameObject;
		self.itemTemplate = self.transform:FindChild("@overlordlistui/Scroll View/Viewport/Content/@itemTemplate").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
	end
	return self;
end
Overlordlist = Overlordlist or CreateOverlordlist();
