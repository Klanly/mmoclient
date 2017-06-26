----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateRoleAttributeUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.levelup = self.transform:FindChild("bgattribute/bgmessage/@levelup").gameObject;
		self.btnchange = self.transform:FindChild("bgattribute/bgmessage/@btnchange").gameObject;
		self.textLevel = self.transform:FindChild("bgattribute/bgmessage/@textLevel").gameObject;
		self.textVocation = self.transform:FindChild("bgattribute/bgmessage/@textVocation").gameObject;
		self.textPeerage = self.transform:FindChild("bgattribute/bgmessage/@textPeerage").gameObject;
		self.textMate = self.transform:FindChild("bgattribute/bgmessage/@textMate").gameObject;
		self.textCamp = self.transform:FindChild("bgattribute/bgmessage/@textCamp").gameObject;
		self.textTitle = self.transform:FindChild("bgattribute/bgmessage/@textTitle").gameObject;
		self.textFaction = self.transform:FindChild("bgattribute/bgmessage/@textFaction").gameObject;
		self.hpBar = self.transform:FindChild("bgattribute/bgprogressBar/@hpBar").gameObject;
		self.textHpdigital = self.transform:FindChild("bgattribute/bgprogressBar/@textHpdigital").gameObject;
		self.mpBar = self.transform:FindChild("bgattribute/bgprogressBar/@mpBar").gameObject;
		self.textpowerdigital = self.transform:FindChild("bgattribute/bgprogressBar/@textpowerdigital").gameObject;
		self.expBar = self.transform:FindChild("bgattribute/bgprogressBar/@expBar").gameObject;
		self.textexperiencedigital = self.transform:FindChild("bgattribute/bgprogressBar/@textexperiencedigital").gameObject;
		self.Content = self.transform:FindChild("bgattribute/Scrollview/Viewport/@Content").gameObject;
		self.attributeItem = self.transform:FindChild("bgattribute/Scrollview/Viewport/@Content/@attributeItem").gameObject;
	end
	return self;
end
RoleAttributeUI = RoleAttributeUI or CreateRoleAttributeUI();
