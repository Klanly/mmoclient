---------------------------------------------------
-- auth： tml
-- date： 2017/01/23
-- desc： 匹配中
---------------------------------------------------

local constant = require "Common/constant"
local arenaScheme = GetConfig('challenge_arena')
local uitext = GetConfig('common_char_chinese').UIText

local function CreateArenaMatchingUICtrl()
	local self = CreateCtrlBase()
	self.layer = LayerGroup.notice
	self.enableCache = false

	local onBackgroundClick = function()
		UIManager.PushView(ViewAssets.ArenaMixMatch,nil, ArenaManager.arenaData, true, constant.ARENA_TYPE.dogfight)
	end

	local onMatchInfoUpdate = function(ty, para)
		if ty == 'start' then
			self.matchingTime.text = ''
		elseif ty == 'tick' then
			self.matchingTime.text = TimeToStr(para)
		elseif ty == 'stop' then
			self.matchingTime.text = ''
			self.close()
		end
	end

    local onMatchInfoUpdate = function(ty, para, para2)
    	-- 正在匹配对手
        if ty == 'start' then
        	self.view.matchingGroup:SetActive(true)
			self.view.matchingTime:GetComponent("TextMeshProUGUI").text = ''
		elseif ty == 'tick' then
        	self.view.matchingGroup:SetActive(true)
			self.view.matchingTime:GetComponent("TextMeshProUGUI").text = TimeToStr(para)
		elseif ty == 'stop' then
			self.view.matchingTime:GetComponent("TextMeshProUGUI").text = ''
			self.close()
		end

		-- 自己已经准备就绪
        if ty == 'fight_ready' then
            self.view.readyGroup:SetActive(true)
            self.view.readyText:GetComponent("TextMeshProUGUI").text = "正在等待其他玩家.."
        elseif ty == 'fight_enter' then
            self.view.readyGroup:SetActive(false)
            self.close()
        end

        
    end

    local onFightInfoClick = function()
    	local data = {}
		data.func_name = 'on_get_arena_dogfight_fight_score'
		MessageManager.RequestLua(constant.CD_MESSAGE_LUA_GAME_RPC, data)		
	end
	self.GetArenaDogfightFightScore = function(data)
		table.print(data, '----- GetArenaDogfightFightScore ----')
		UIManager.UnloadView(ViewAssets.ArenaResult)
		UIManager.PushView(ViewAssets.ArenaResult,nil, data.score_data)
	end

	self.onLoad = function()
		self.view.machingLabel:GetComponent("TextMeshProUGUI").text = uitext[1135002].NR

		self.view.matchingGroup:SetActive(false)
		self.view.readyGroup:SetActive(false)
		self.view.arenaProGroup:SetActive(false)

        ClickEventListener.Get(self.view.bg1).onClick = onBackgroundClick
        ClickEventListener.Get(self.view.bg2).onClick = onBackgroundClick

		ArenaManager.AddMatchListener(onMatchInfoUpdate)
		-- UIUtil.SetFullFromParentEdge(self.view.transform)
  --       self.view.transform.anchorMin = Vector2.New(0,0)
  --       self.view.transform.anchorMax = Vector2.New(1,1)
        -- ClickEventListener.Get(self.view.btnFightInfo).onClick = onFightInfoClick
        -- UIUtil.AddButtonEffect(self.view.btnFightInfo, nil, nil)
  
	end
	
	self.onUnload = function()
		ArenaManager.RemoveMatchListener(onMatchInfoUpdate)
	end
	
	return self
end

return CreateArenaMatchingUICtrl()