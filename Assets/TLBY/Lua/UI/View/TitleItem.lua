----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTitleItem()
	local self = CreateViewBase();
	local data = nil
	
	local OnClick = function()

		if data.SelectRankItemRet then
		
			data.SelectRankItemRet(data.pos)
		end
	end
	
	self.Awake = function()
		self.bgblackarticle = self.transform:FindChild("@bgblackarticle").gameObject;
		self.bgwhitearticle = self.transform:FindChild("@bgwhitearticle").gameObject;
		self.textnumber = self.transform:FindChild("@textnumber").gameObject;
		self.textemperor = self.transform:FindChild("@textemperor").gameObject;
		

		ClickEventListener.Get(self.bgblackarticle).onClick = OnClick
	end
	
	self.SetPos = function(inpos,offset)
        local vpos = Vector3.New(-286 + ((inpos - 1) % 5) * 145,offset - 80 - math.floor((inpos - 1) / 5) * 145,0)
        self.transform.anchoredPosition3D = vpos
        self.bgwhitearticle:SetActive(false)
	end
	
	
	self.SetData = function(initData)
	
		data = initData
		if data.select then
		
			self.bgwhitearticle:SetActive(true)
		else
		
			self.bgwhitearticle:SetActive(false)
		end
		
		self.textnumber:GetComponent('TextMeshProUGUI').text = data.attr.Describe
		self.textemperor:GetComponent('TextMeshProUGUI').text = data.attr.Name1
	end
	
	return self;
end

return CreateTitleItem()
