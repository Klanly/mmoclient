----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateModifyNameUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.Modifyname = self.transform:FindChild("@Modifyname").gameObject;
		self.com_btn_3_2 = self.transform:FindChild("@Modifyname/@com_btn_3_2").gameObject;
		self.com_text_btn_3_2 = self.transform:FindChild("@Modifyname/@com_text_btn_3_2").gameObject;
		self.com_btn_3_1 = self.transform:FindChild("@Modifyname/@com_btn_3_1").gameObject;
		self.com_text_btn_3_1 = self.transform:FindChild("@Modifyname/@com_text_btn_3_1").gameObject;
		self.com_btnclose2 = self.transform:FindChild("@Modifyname/@com_btnclose2").gameObject;
		self.com_text_s1 = self.transform:FindChild("@Modifyname/@com_text_s1").gameObject;
		self.textEntername = self.transform:FindChild("@Modifyname/@textEntername").gameObject;
		self.icondice = self.transform:FindChild("@Modifyname/@icondice").gameObject;
		self.com_frame_white = self.transform:FindChild("@Modifyname/@com_frame_white").gameObject;
		self.icon1 = self.transform:FindChild("@Modifyname/@icon1").gameObject;
		self.com_text_s3 = self.transform:FindChild("@Modifyname/@com_text_s3").gameObject;
	end
	return self;
end
ModifyNameUI = ModifyNameUI or CreateModifyNameUI();
