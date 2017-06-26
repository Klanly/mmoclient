----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePetMergeEatAttributeUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("bg/@btnClose").gameObject;
		self.attributeScrollView = self.transform:FindChild("@attributeScrollView").gameObject;
		self.attributeItem = self.transform:FindChild("@attributeScrollView/Viewport/content/@attributeItem").gameObject;
	end
	return self;
end
PetMergeEatAttributeUI = PetMergeEatAttributeUI or CreatePetMergeEatAttributeUI();
