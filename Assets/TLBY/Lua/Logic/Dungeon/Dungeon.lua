---------------------------------------------------
-- auth： panyinglong
-- date： 2016/10/21
-- desc： 副本
---------------------------------------------------

local itemTable = require "Logic/Scheme/common_item"
local dungeonTable = require "Logic/Scheme/challenge_main_dungeon"
local texttable = require "Logic/Scheme/common_char_chinese"

function CreateDungeon(configData, bestGrade, index)
	local self = CreateObject()
	self.LordName = '' -- 霸主名
	-- 副本的属性
	self.ID = configData.ID
	self.Name = configData.Name1 -- texttable.TableText[math.floor(configData.Name)].NR
	self.Chapter = configData.Chapter
	self.SceneID = configData.SceneID
	self.SceneSetting = configData.SceneSetting	
	self.ChapterDes = configData.ChapterDes1 --texttable.UIText[math.floor(configData.ChapterDes)].NR
	self.RecommendPower	= configData.RecommendPower
	self.Level = configData.Level	
	self.Time = configData.Time/1000	 -- 配置表为毫秒制
	self.type = configData.type	 --1：杀死目标单位。2：保卫目标单位到目标时间结束。3：护送目标到目标地。4：角色移动到目标地点。
	self.element1 = configData.element1	
	self.element2 = configData.element2	
	self.EnterAnimation = configData.EnterAnimation	
	self.EnterDialogue = configData.EnterDialogue	
	self.BackgroundImage = configData.BackgroundImage	
	self.Reward1 = configData.Reward1	
	self.Reward2 = configData.Reward2	
	self.Reward3 = configData.Reward3	
	self.Reward4 = configData.Reward4	
	self.ProDrop1 = configData.ProDrop1	
	self.ProDrop2 = configData.ProDrop2	
	self.SceneResources = configData.SceneResources
	self.index = index

	local gradeTable = dungeonTable.TranscriptMark
	local chapterData = dungeonTable.Chapter[self.Chapter]
	self.ChapterName = texttable.TableText[math.floor(chapterData.Name)].NR
	
	-- 每日次数和体力消耗
	self.Consume = EnergyManager.GetConsume()

	-- 最好成绩
	self.bestGrade = bestGrade

	self.drops = {}

	self.grade = DungeonGrade.NotPass -- 评级sss ss s a b c

	local init = function()		
		for i = 1, 4 do
			if type(self['Reward' .. i]) == 'table' and #self['Reward' .. i] == 2 then
				local drop = {}
				drop.itemID = self['Reward' .. i][1]
				drop.num = self['Reward' .. i][2]
				drop.isSure = true
				table.insert(self.drops, drop)
			end
		end
		for i = 1, 2 do
			if type(self['ProDrop' .. i]) == 'table' and #self['ProDrop' .. i] == 1 then
				local drop = {}
				drop.itemID = self['ProDrop' .. i][1]
				drop.isSure = false
				table.insert(self.drops, drop)
			end
		end
	end
	--更新评级
	local updateGrade = function(time)
		if self.Time > 0 then
			local timePro = (self.Time - time)/self.Time
			for k, v in ipairs(gradeTable) do
				if timePro >= (v.RestTime/100) then
					return v.Ranking, v.RewardPoints
				end
			end
		else
			return DungeonGrade.NotPass, 0
		end
	end

	self.UpdateBestGrade = function(time)
		self.bestGrade = updateGrade(time)
	end

	self.GetSNum = function()
		if self.bestGrade == DungeonGrade.SSS then
			return 3
		elseif self.bestGrade == DungeonGrade.SS then
			return 2
		elseif self.bestGrade == DungeonGrade.S then
			return 1
		end
		return 0
	end

	init()
	return self
end
