----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateUnionMemberUICtrl()
	local self = CreateViewBase()
	self.memberIndex = 0
	self.SelectAction = nil
	
	local OnSelect = function()
		if self.SelectAction then
			self.SelectAction(self.memberIndex)
		end
	end
	
	self.SetSelect = function(flag)
		self.bgselectarticle:SetActive(flag)
	end

	self.Awake = function()
		self.unionid = self.transform:FindChild("unionid").gameObject		--帮会ID
		self.unionidText = self.unionid:GetComponent('TextMeshProUGUI')
		self.unionname = self.transform:FindChild("unionname").gameObject	--帮会名称
		self.unionnameText = self.unionname:GetComponent('TextMeshProUGUI')
		self.unionlevel = self.transform:FindChild("unionlevel").gameObject	--帮会等级
		self.unionlevelText = self.unionlevel:GetComponent('TextMeshProUGUI')
		self.unionnum = self.transform:FindChild("unionnum").gameObject		--帮会人数
		self.unionnumText = self.unionnum:GetComponent('TextMeshProUGUI')
		self.unionowner = self.transform:FindChild("unionowner").gameObject	--帮主
		self.hasrequested = self.transform:FindChild("hasrequested").gameObject	--已申请标志
		self.hasrequested:SetActive(false)
		self.topflag = self.transform:FindChild("topflag").gameObject	--置顶标志
		self.bgredbox = self.transform:FindChild("bgredbox").gameObject
		self.unionownerText = self.unionowner:GetComponent('TextMeshProUGUI')
		self.bgblackarticle = self.transform:FindChild("bgblackarticle").gameObject
		self.bgwhitearticle = self.transform:FindChild("bgwhitearticle").gameObject
		self.bgselectarticle = self.transform:FindChild("bgselectarticle").gameObject
		ClickEventListener.Get(self.bgblackarticle).onClick = OnSelect
		ClickEventListener.Get(self.bgwhitearticle).onClick = OnSelect
	end
	
	return self
end

return CreateUnionMemberUICtrl()
