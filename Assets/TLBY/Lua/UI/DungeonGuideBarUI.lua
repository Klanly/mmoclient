require "Common/basic/LuaObject"
local const = require "Common/constant"

local function CreateDungeonGuideBarUI()
    local self = CreateObject()
    local target = nil
    local followTransform = nil
	local localRotation = nil
    local flagUIGo = nil
    local currentDungeonManager = nil
    local paths = nil
    local pathPosFlags = nil
	local distance = 5
    local initPathData = function()
		if not currentDungeonManager then
			if SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.MAIN_DUNGEON then 			--主线副本
				currentDungeonManager = MainDungeonManager
			elseif SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.TEAM_DUNGEON then  		--组队副本
				currentDungeonManager = TeamDungeonManager
			elseif SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.TASK_DUNGEON then  		--任务副本
				currentDungeonManager = TaskDungeonManager
			else
				error('不是副本，不能添加指路标示')
			end
		end
		paths,pathPosFlags = currentDungeonManager.getDungeonPaths()
		currentDungeonManager.nextPositionIndex = -1 
		if not paths or #paths == 0 then
			error('没有找到副本path')
		end
	end
    self.Awake = function()
		self.transform = self.gameObject.transform
		flagUIGo = self.transform:FindChild("UI").gameObject;
		flagUIGo:SetActive(false)

		initPathData()
    end
    
    self.OnDisable = function()
        LateUpdateBeat:Remove(self.LateUpdate, self)
        followTransform = nil
    end
    
    self.OnEnable = function()
        LateUpdateBeat:Add(self.LateUpdate, self)
     end
	
	local UpdateRotate = function(pos)
		local forward = pos - followTransform.position
		local mag = forward:Magnitude()
		if mag < 0.01 then
            flagUIGo:SetActive(false)
			return
		end
		local targetrot = Quaternion.LookRotation(forward)
		self.transform.localEulerAngles = Vector3.New(0,targetrot.eulerAngles.y -180,0)
		self.transform.position = Vector3.New(followTransform.position.x,followTransform.position.y, followTransform.position.z) + (pos - followTransform.position).normalized* 2
    end
	
	local updatePositionIndex =function()
		  if currentDungeonManager.nextPositionIndex == -1 then
			   currentDungeonManager.nextPositionIndex = 1
		  end
		  local hero = SceneManager.GetEntityManager().hero
		  if not hero or hero:IsDestroy() then
		  	return
		  end
		 if #paths < 1 or currentDungeonManager.nextPositionIndex > #paths then return end
		 local dis = Vector3.Distance2D(hero:GetPosition(), paths[currentDungeonManager.nextPositionIndex])
		 if pathPosFlags[currentDungeonManager.nextPositionIndex] == 0  then
			distance = 5
		 else
			distance = 0.8
		 end
		 if dis < distance then
		   currentDungeonManager.nextPositionIndex = currentDungeonManager.nextPositionIndex + 1
		 end
	end
    
    self.LateUpdate = function()
        if not IsNil(followTransform) then
			local target = nil
			local pos = nil
            local posIndex = -1
			updatePositionIndex()
			flagUIGo:SetActive(false)
			local hero = SceneManager.GetEntityManager().hero
			if not hero or hero:IsDied() or hero:IsDestroy() then
				return
			end
			if hero.target  or TargetManager.GetCurrentTarget() ~= nil then
				return
			else
			      target = TargetManager.GetCloestMonster()
				if target and not target:IsDied() then
				    pos = target:GetPosition()
				end
			end
			if pos then
				flagUIGo:SetActive(true)
				UpdateRotate(pos)
				return
			end
			posIndex = currentDungeonManager.nextPositionIndex
		    if currentDungeonManager.nextPositionIndex > #paths then 
			   posIndex = #paths
		    end
			flagUIGo:SetActive(true)
			UpdateRotate(paths[posIndex])
        end
    end
    
    self.UpdatePos = function(puppetBehavior)
        self.gameObject:SetActive(true)
		followTransform = puppetBehavior.transform
	end
   
    return self
end

return CreateDungeonGuideBarUI()