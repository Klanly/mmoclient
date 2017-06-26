----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTitleDescrip()
	local self = CreateViewBase();
	self.Awake = function()
		self.bgpopupwindow = self.transform:FindChild("@bgpopupwindow").gameObject;
		self.btnquit = self.transform:FindChild("@bgpopupwindow/@btnquit").gameObject;
		self.textdonationmessage = self.transform:FindChild("@bgpopupwindow/@textdonationmessage").gameObject;
		self.texttitle = self.transform:FindChild("@bgpopupwindow/@texttitle").gameObject;
		self.textdonationnumber = self.transform:FindChild("@bgpopupwindow/@textdonationnumber").gameObject;
		self.btndetermine = self.transform:FindChild("@bgpopupwindow/@btndetermine").gameObject;
		self.ScrollView = self.transform:FindChild("@ScrollView").gameObject;
		self.ScrollViewContent = self.transform:FindChild("@ScrollView/ViewPort/@ScrollViewContent").gameObject;
	end
	return self;
end
TitleDescrip = TitleDescrip or CreateTitleDescrip();
