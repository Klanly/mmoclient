----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateMailUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnFriend = self.transform:FindChild("tabs/@btnFriend").gameObject;
		self.btnMail = self.transform:FindChild("tabs/@btnMail").gameObject;
		self.mailRed = self.transform:FindChild("tabs/@mailRed").gameObject;
		self.pageLeft = self.transform:FindChild("@pageLeft").gameObject;
		self.textMailCount = self.transform:FindChild("@pageLeft/@textMailCount").gameObject;
		self.scrollView = self.transform:FindChild("@pageLeft/@scrollView").gameObject;
		self.mailItem = self.transform:FindChild("@pageLeft/@scrollView/Viewport/content/@mailItem").gameObject;
		self.pageRight = self.transform:FindChild("@pageRight").gameObject;
		self.scrollViewContent = self.transform:FindChild("@pageRight/Scrollview/Viewport/@scrollViewContent").gameObject;
		self.contentLayout = self.transform:FindChild("@pageRight/Scrollview/Viewport/@scrollViewContent/@contentLayout").gameObject;
		self.mailContent = self.transform:FindChild("@pageRight/Scrollview/Viewport/@scrollViewContent/@contentLayout/bg/@mailContent").gameObject;
		self.mailTitle = self.transform:FindChild("@pageRight/Scrollview/Viewport/@scrollViewContent/@contentLayout/bg/bgarenaranking/@mailTitle").gameObject;
		self.textDate = self.transform:FindChild("@pageRight/Scrollview/Viewport/@scrollViewContent/@contentLayout/bg/date/@textDate").gameObject;
		self.textSender = self.transform:FindChild("@pageRight/Scrollview/Viewport/@scrollViewContent/@contentLayout/bg/date/@textSender").gameObject;
		self.attachLayout = self.transform:FindChild("@pageRight/Scrollview/Viewport/@scrollViewContent/@attachLayout").gameObject;
		self.attachs = self.transform:FindChild("@pageRight/Scrollview/Viewport/@scrollViewContent/@attachLayout/@attachs").gameObject;
		self.attachs = self.transform:FindChild("@pageRight/Scrollview/Viewport/@scrollViewContent/@attachLayout/@attachs/@attachs").gameObject;
		self.attachItem = self.transform:FindChild("@pageRight/Scrollview/Viewport/@scrollViewContent/@attachLayout/@attachs/@attachs/@attachItem").gameObject;
		self.btnDeleteSelect = self.transform:FindChild("btns/@btnDeleteSelect").gameObject;
		self.btnDelectAll = self.transform:FindChild("btns/@btnDelectAll").gameObject;
		self.btnGetAll = self.transform:FindChild("btns/@btnGetAll").gameObject;
		self.btnGetSelect = self.transform:FindChild("btns/@btnGetSelect").gameObject;
		self.btnHelp = self.transform:FindChild("btns/@btnHelp").gameObject;
		self.btnClose = self.transform:FindChild("btns/@btnClose").gameObject;
		self.empty = self.transform:FindChild("@empty").gameObject;
	end
	return self;
end
MailUI = MailUI or CreateMailUI();
