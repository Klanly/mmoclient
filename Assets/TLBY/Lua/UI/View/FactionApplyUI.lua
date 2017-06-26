----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateFactionApplyUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClear = self.transform:FindChild("bgmiddlelist/@btnClear").gameObject;
		self.btnAllComfirm = self.transform:FindChild("bgmiddlelist/@btnAllComfirm").gameObject;
		self.empty = self.transform:FindChild("@empty").gameObject;
		self.scrollView = self.transform:FindChild("@scrollView").gameObject;
		self.item = self.transform:FindChild("@scrollView/Viewport/content/@item").gameObject;
		self.btnBack = self.transform:FindChild("@btnBack").gameObject;
	end
	return self;
end
FactionApplyUI = FactionApplyUI or CreateFactionApplyUI();
