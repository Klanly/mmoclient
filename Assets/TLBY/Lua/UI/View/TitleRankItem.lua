----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTitleRankItem()
	local self = CreateViewBase();
	local data = nil
	
	local OnClick = function()

		if data.SelectRankItemRet then
		
			data.SelectRankItemRet(data.pos)
		end
	end
	
	local OnShowTip = function()
	
		UIManager.PushView(ViewAssets.CommTextTipUI,
			function(ctrl)
				local nobleRank = data.attr.noble_rank
				local describe = pvpCamp.NobleRank[nobleRank].Describe
				ctrl.SetData(describe)
				ctrl.SetPosition(self.texttitlename2.transform.position)
			end)
	end
	
	self.Awake = function()
		self.TitleRankBg = self.transform:FindChild("@TitleRankBg").gameObject;
		self.bgwhitearticle = self.transform:FindChild("@bgwhitearticle").gameObject;
		self.textpsychic1 = self.transform:FindChild("@textpsychic1").gameObject;
		self.texttitlename2 = self.transform:FindChild("@texttitlename2").gameObject;
		self.textplayernamemessage = self.transform:FindChild("@textplayernamemessage").gameObject;
		self.textrankingnumber1 = self.transform:FindChild("@textrankingnumber1").gameObject;
		self.textobtainnumber1 = self.transform:FindChild("@textobtainnumber1").gameObject;
		self.TopIcon = self.transform:FindChild("@Top/@TopIcon").gameObject;
		self.Top = self.transform:FindChild("@Top").gameObject;
		
		ClickEventListener.Get(self.texttitlename2).onClick = OnShowTip
		ClickEventListener.Get(self.TitleRankBg).onClick = OnClick
	end
	
	self.SetPos = function(inpos,offset)
        local vpos = Vector3.New(-286 + ((inpos - 1) % 5) * 145,offset - 80 - math.floor((inpos - 1) / 5) * 145,0)
        self.transform.anchoredPosition3D=vpos
        self.bgwhitearticle:SetActive(false)
	end
	
	self.SetData = function(initData)
	
		data = initData
		if data.select then
		
			self.bgwhitearticle:SetActive(true)
		else
		
			self.bgwhitearticle:SetActive(false)
		end
		
		local nobleRank = data.attr.noble_rank
		local donation = data.attr.donation
		local titleData =  pvpCamp.NobleRank[nobleRank]
		if not donation then
			
			donation = data.attr.weekly_donation
		end
		
		self.texttitlename2:GetComponent('TextMeshProUGUI').text = titleData.Name1  --当前爵位
		self.textplayernamemessage:GetComponent('TextMeshProUGUI').text = data.attr.actor_name --角色名称
		self.textobtainnumber1:GetComponent('TextMeshProUGUI').text = donation --贡献值
		self.textpsychic1:GetComponent('TextMeshProUGUI').text = '+'..data.attr.Gain.."灵力"	--灵力
		--data.attr.actor_id --角色ID
		
		if data.rankIndex <= 3 then		--前三名
		
			self.Top:SetActive(true)
			self.TopIcon:GetComponent('Image').overrideSprite = ResourceManager.LoadSprite(string.format("AutoGenerate/Petappearance/%s", data.rankIndex))
			self.textrankingnumber1:SetActive(false)
		else
		
			self.Top:SetActive(false)
			self.textrankingnumber1:SetActive(true)
			self.textrankingnumber1:GetComponent('TextMeshProUGUI').text = data.rankIndex   --排名
		end

	end
	
	return self
end

return CreateTitleRankItem()
