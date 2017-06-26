----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateFriendsList()
	local self = CreateViewBase();
	self.Awake = function()
		self.bgchat = self.transform:FindChild("@bgchat").gameObject;
		self.textchat = self.transform:FindChild("@bgchat/@textchat").gameObject;
		self.titlethree = self.transform:FindChild("@titlethree").gameObject;
		self.texttitlethree = self.transform:FindChild("@titlethree/@texttitlethree").gameObject;
		self.textdegreethree = self.transform:FindChild("@titlethree/@textdegreethree").gameObject;
		self.paginleftgui = self.transform:FindChild("@paginleftgui").gameObject;
		self.textleftfriendmessage = self.transform:FindChild("@paginleftgui/bgleftfriend/@textleftfriendmessage").gameObject;
		self.textleftnickname = self.transform:FindChild("@paginleftgui/bgleftfriend/@textleftnickname").gameObject;
		self.textbtnblacklist = self.transform:FindChild("@paginleftgui/btnblacklistgui/@textbtnblacklist").gameObject;
		self.textbtnfriendgui = self.transform:FindChild("@paginleftgui/btnfriendgui/@textbtnfriendgui").gameObject;
		self.textbtnstanger = self.transform:FindChild("@paginleftgui/btnstranger/@textbtnstanger").gameObject;
		self.textbtnememy = self.transform:FindChild("@paginleftgui/btnememy/@textbtnememy").gameObject;
	end
	return self;
end
FriendsList = FriendsList or CreateFriendsList();
