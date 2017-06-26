-- auth： zhangzeng
-- date： 2017/6/5
require "UI/View/LuaViewBase"

fix_string = {
	n_day = '%s天',
	n_hour = '%s小时',
	n_min = '%s分',
	n_sec = '%s秒',
}

local string_format = string.format
local SEC_OF_MIN = 60
local SEC_OF_HOUR = 3600
local SEC_OF_DAY = 86400
local function get_time_str_from_sec(sec)
    local time_str = ""
    if sec <= 0 then
        _error("get_election_basic_info, remaining_sec error "..tostring(sec))
        return ""
    end

    local last_day = math.ceil(sec / SEC_OF_DAY)
    if last_day > 1 then
        time_str = string_format(fix_string.n_day, last_day)
        return time_str
    end
    local last_hour = math.ceil(sec / SEC_OF_HOUR)
    if last_hour > 1 then
        time_str = string_format(fix_string.n_hour, last_hour)
        return time_str
    end
    local last_min = math.ceil(sec / SEC_OF_MIN)
    if last_min > 1 then
        time_str = string_format(fix_string.n_min, last_min)
        return time_str
    end
    time_str = string_format(fix_string.n_sec, sec)
    return time_str
end

local function CreateCampOfficefuncItem()
	local self = CreateViewBase()
	local timeInfo
	local cdTime
	local skillName
	self.data = nil
	
	self.Awake = function()
		self.text2 = self.transform:FindChild("text2").gameObject;
		self.btnelection1 = self.transform:FindChild("btnelection1").gameObject;
		self.btnreset = self.transform:FindChild("btnreset").gameObject
		self.cdtime = self.transform:FindChild("cdtime").gameObject
		self.com_text_btn_3_1 = self.btnelection1.transform:FindChild("com_text_btn_3_1").gameObject;
		
		ClickEventListener.Get(self.btnreset).onClick = self.Reset
		MessageRPCManager.AddUser(self, 'GetRefreshSkillCdMoneyNeedRet')
	end
	
	self.OnDestroy = function()
		if timeInfo then
			Timer.Remove(timeInfo)
			timeInfo = nil
		end
		MessageRPCManager.RemoveUser(self, 'GetRefreshSkillCdMoneyNeedRet')
	end

	self.SetData = function(data)
		self.data = data
	end
	
	self.SetSkillName = function(skillname)
		skillName = skillname
	end
	
	self.ShowTimeStr = function()
		cdTime = cdTime - 1
		local timeStr = get_time_str_from_sec(cdTime)
		self.cdtime:GetComponent('TextMeshProUGUI').text = '剩余：'..timeStr
	end
	
	self.SetCDTime = function(cdtime)
		self.cdtime:SetActive(true)
		local timeStr = get_time_str_from_sec(cdtime)
		cdTime = cdtime
		self.cdtime:GetComponent('TextMeshProUGUI').text = '剩余：'..timeStr
		self.btnreset:SetActive(true)
		self.btnelection1:SetActive(false)
		if timeInfo then
			Timer.Remove(timeInfo)
		end
		timeInfo = Timer.Repeat(1, self.ShowTimeStr)
	end
	
	self.HideCDTime = function()
		self.cdtime:SetActive(false)
		self.btnreset:SetActive(false)
		self.btnelection1:SetActive(true)
		if timeInfo then
			Timer.Remove(timeInfo)
			timeInfo = nil
		end
	end
	
	self.Reset = function()
		local data = {}
		data.func_name = 'on_get_refresh_skill_cd_money_need'
		data.skill_name = skillName
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.GetRefreshSkillCdMoneyNeedRet = function(data)
		if data.skill_name ~= skillName then
			return
		end
		
		local title = string_format(commonCharChinese.UIText[1135132].NR, data.money_need)
		UIManager.ShowDialog(title, '确定', '取消',
			function()
				local data = {}
				data.func_name = 'on_refresh_skill_cd_with_money'
				data.skill_name = skillName
				MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    		end)
	end
	
	self.Init = function()

	end

	return self
end

return CreateCampOfficefuncItem()
