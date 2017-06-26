---------------------------------------------------
-- auth： panyinglong
-- date： 2016/11/2
-- desc： 章节奖励
---------------------------------------------------
local itemTable = require "Logic/Scheme/common_item"
local dungeonTable = require "Logic/Scheme/challenge_main_dungeon"

ChapterRewardState = {
	CannotGet = 1, 
	CanButNotGet = 2,
	GetOver = 3,
}

function CreateChapterReward(chapter, index)
	local self = CreateObject()

	self.chapter = chapter
	
	self.SIndex = index
	self.SnumText = ""
	self.Snum = 5
	if self.SIndex == 1 then
		self.SnumText = "5S"
		self.Snum = 5
	elseif self.SIndex == 2 then
		self.SnumText = "10S"
		self.Snum = 10
	elseif self.SIndex == 3 then
		self.SnumText = "15S"
		self.Snum = 15
	end

	self.currentSnum = 0
		
	self.RewardState = ChapterRewardState.CannotGet
	self.Rewards = {}
	
	local initRewards = function()
		local chapterScheme = dungeonTable.Chapter
		if chapterScheme[self.chapter] then
			local rewardConfig = chapterScheme[self.chapter]['Rewar'..self.SIndex]
			for i = 1, #rewardConfig, 2 do
				if rewardConfig[i] and rewardConfig[i + 1] then
					self.Rewards[rewardConfig[i]] = rewardConfig[i + 1]
				end
			end
		end
	end
	self.updateState = function(b)
		if b then
			self.RewardState = ChapterRewardState.GetOver
		else
			if self.currentSnum >= self.Snum then
				self.RewardState = ChapterRewardState.CanButNotGet
			else
				self.RewardState = ChapterRewardState.CannotGet
			end
		end
	end
	self.updateCurrSnum = function(num)
		self.currentSnum = num
	end

	initRewards()
	return self
end