----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateUnLockPetSkillTipUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.Title = self.transform:FindChild("@Title").gameObject;
		self.Close = self.transform:FindChild("@Close").gameObject;
		self.Ok = self.transform:FindChild("@Ok").gameObject;
		self.OkText = self.transform:FindChild("@OkText").gameObject;
		self.ScrollView = self.transform:FindChild("@ScrollView").gameObject;
		self.Content = self.transform:FindChild("@ScrollView/Viewport/@Content").gameObject;
	end
	return self;
end
UnLockPetSkillTipUI = UnLockPetSkillTipUI or CreateUnLockPetSkillTipUI();
