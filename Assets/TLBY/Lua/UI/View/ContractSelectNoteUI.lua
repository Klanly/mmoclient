----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateContractSelectNoteUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.text = self.transform:FindChild("@text").gameObject;
	end
	return self;
end
ContractSelectNoteUI = ContractSelectNoteUI or CreateContractSelectNoteUI();
