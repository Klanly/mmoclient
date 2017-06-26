---------------------------------------------------
-- auth： panyinglong
-- date： 2016/11/2
-- desc： 章　副本
---------------------------------------------------

local DungeonScheme = challengeMainDungeonScheme
local texttable = require "Logic/Scheme/common_char_chinese"

function CreateChapter(chapter)
	local self = CreateObject()
	self.cfg = DungeonScheme.Chapter[chapter]
	if not self.cfg then
		error('没有找到chapter config id = ' .. chapter)
	end
	self.chapter = chapter
	self.chapterRewards = {}
	self.dungeonNum = 0
	self.name = self.cfg.Name1
	self.rank = self.cfg.Rank1

	self.dungeons = {}

	self.getDungeon = function(id)
		for _, v in ipairs(self.dungeons)do
			if v.ID == id then
				return v
			end
		end
		return nil
	end
	self.getSNum = function()
		local n = 0
		for id, v in ipairs(self.dungeons)do
			n = n + v.GetSNum()
		end
		return n		
	end
	self.getTotalSNum = function()	
		return self.dungeonNum * 3
	end

	self.udpateRewardState = function(data)
		for i = 1, 3 do
			if data[i] then
			 	self.chapterRewards[i].updateState(data[i])
			else
			 	self.chapterRewards[i].updateState(false)
			end
		end			
	end

	self.updateSNum = function()
		local num = self.getSNum()
		for i = 1, 3 do
			self.chapterRewards[i].updateCurrSnum(num)
			self.chapterRewards[i].updateState()
		end
	end

	local create = function()
		local scheme = DungeonScheme.NormalTranscript

		for k, v in ipairs(scheme) do
			if v.Chapter == self.chapter then
				local dungeon = CreateDungeon(v, DungeonGrade.Locked, k)
				table.insert(self.dungeons, dungeon)
			end
			self.dungeonNum = #self.dungeons
		end
		self.chapterRewards = {}
		for i = 1, 3 do -- 注１为５Ｓ，２为１０Ｓ，　３为１５Ｓ
			self.chapterRewards[i] = CreateChapterReward(chapter, i)
		end
	end
	create()
	return self
end