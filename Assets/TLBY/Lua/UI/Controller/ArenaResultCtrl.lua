---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/1
-- desc： 
---------------------------------------------------

require "UI/Controller/LuaCtrlBase"
local roleScheme = GetConfig('system_login_create')

local function CreateArenaResultCtrl()
	local self = CreateCtrlBase()
	self.rankData = {}

	local onItemUpdate = function(go, index)
		local bgranking1 = go.transform:FindChild('bgranking1').gameObject:GetComponent('Image')
		local name = go.transform:FindChild('name').gameObject:GetComponent('TextMeshProUGUI')
		local sceneScore = go.transform:FindChild('sceneScore').gameObject:GetComponent('TextMeshProUGUI')
		local robScore = go.transform:FindChild('robScore').gameObject:GetComponent('TextMeshProUGUI')
		local score = go.transform:FindChild('score').gameObject:GetComponent('TextMeshProUGUI')
		local vacation = go.transform:FindChild('vacation').gameObject:GetComponent('TextMeshProUGUI')
		local rankImg = go.transform:FindChild('rankImg').gameObject:GetComponent('Image')
		local rankText = go.transform:FindChild('rankText').gameObject:GetComponent('TextMeshProUGUI')

		local data = self.rankData[index + 1]
		if data.rank <= 3 then
			rankText.gameObject:SetActive(false)
			rankImg.gameObject:SetActive(true)
			rankImg.sprite = ResourceManager.LoadSprite('AutoGenerate/Petappearance/'..data.rank)
		else
			rankText.gameObject:SetActive(true)
			rankImg.gameObject:SetActive(false)
			rankText.text = data.rank
		end 
		local color = '#272020'
		if data.uid == MyHeroManager.heroData.entity_id then
			color = '#2B8100'
		end
		name.text = '<color='.. color .. '>' .. data.name .. '</color>'
		sceneScore.text =  '<color='.. color .. '>' .. data.sceneScore .. '</color>'
		robScore.text = data.robScore
		score.text =  '<color='.. color .. '>' .. data.score .. '</color>'
		vacation.text =  '<color='.. color .. '>' .. data.vacation .. '</color>'

		if index % 2 == 0 then
			bgranking1.sprite = ResourceManager.LoadSprite('AutoGenerate/ArenaResult/bgranking1')
		else
			bgranking1.sprite = ResourceManager.LoadSprite('AutoGenerate/ArenaResult/bgranking2')
		end
	end

	local showResult = function(data)
		self.scrollview = self.view.resultSV:GetComponent(typeof(UIMultiScroller))
	    UIUtil.AddButtonEffect(self.view.btnclose2, nil, nil)
	    ClickEventListener.Get(self.view.btnclose2).onClick = function()
	    	self.close()
	    	if ArenaManager.isFightOver then
	    		ArenaManager.RequestOverMixFight()
	    	end
	    end
	    
		for k, v in ipairs(data) do
			table.insert(self.rankData, {
				uid = v.actor_id,
				rank = v.rank,
				name = v.actor_name,
				sceneScore = v.scene_score,
				robScore = v.plunder_score,
				score = v.total_score,
				vacation = roleScheme.RoleModel[v.vocation].Name1,
			})
		end
		self.scrollview:Init(self.view.itemTemplate, 1462, 100, 5, 10, 1)		
		self.scrollview:UpdateData(#self.rankData, onItemUpdate)
		self.view.itemTemplate:SetActive(false)
	end

	self.onLoad = function(data)
		if ArenaManager.isFightOver then
    		self.view.overImg:SetActive(true)
			self.view.overImg.transform.localScale = Vector3.New(0, 0, 0)
			BETween.scale(self.view.overImg, 0.5, Vector3.New(1, 1, 1))
			self.view.Settlementui:SetActive(false)
			local delay = GetConfig('challenge_arena').Parameter[27].Value[1]/1000
			Timer.Delay(delay, function()
				if self.isLoaded then
					self.view.Settlementui:SetActive(true)
					showResult(data)
				end
			end)
    	else
			self.view.Settlementui:SetActive(true)
    		showResult(data)
    	end
	end

	self.onUnload = function()
		self.rankData = {}
	end

	return self
end

return CreateArenaResultCtrl()