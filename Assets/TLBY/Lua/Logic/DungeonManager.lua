---------------------------------------------------
-- auth： panyinglong
-- date： 2017/3/28
-- desc： 副本管理基类
---------------------------------------------------
require "Common/basic/LuaObject"
require "Network/MessageManager"
require "Logic/SceneManager"
require "Logic/Dungeon/Chapter"
require "Logic/Dungeon/Dungeon"
require "Logic/Dungeon/ChapterReward"

local const = require "Common/constant"
-- DungeonType = {
-- 	Normal = 1,	-- 普通副本　
-- 	Elite = 2,	-- 精英副本
-- 	Team = 3,	-- 团队副本
-- };

DungeonGrade = {
	SSS = 'SSS',
	SS = 'SS',
	S = 'S',
	A = 'A',
	B = 'B',
	C = 'C',
	NotPass = 'not_pass',
	Locked = 'locked'
}

local function CreateDungeonPath()
	local pathPos = {}
	local pathPosFlag = {}
	local sceneObjectTable = nil
	local SceneObj = nil
	local ToPos = function(posStr)
	  local t = {}
	  local posStrArr = string.split(posStr, '|')
	  local flag = 0
	  for i = 1, #posStrArr do
		local itemStrArr = string.split(posStrArr[i], '*')
		local pos
		if #itemStrArr == 3 then
		   pos = Vector3.New(itemStrArr[1]/1, itemStrArr[2]/1, itemStrArr[3]/1)
		   flag = 0
		elseif #itemStrArr == 1 then
		   flag = 1
		  sceneObjectTable = SceneManager.GetCurSceneLayoutScheme()
		  SceneObj = sceneObjectTable[tonumber(itemStrArr[1])]
		  pos = Vector3.New(SceneObj.PosX/1, SceneObj.PosY/1, SceneObj.PosZ/1)
		end
		table.insert(t, pos)
		pathPosFlag[i] = flag
	  end
	  return t
	 end
	pathPos = ToPos(SceneManager.GetCurSceneData().Path)
    return pathPos,pathPosFlag
end

local function CreateDungeonManager()
	local self = CreateObject()
	self.nextPositionIndex = -1

	self.getDungeonPaths = function()
		return CreateDungeonPath()
	end
	
	return self
end
return CreateDungeonManager