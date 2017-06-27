---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/29
-- desc： aoi管理
---------------------------------------------------
require "Common/basic/LuaObject"
local Const = require "Common/constant"
local mp = require '3rd/messagepack/MessagePack'
local log = require "basic/log"

local CreateAOIManager = function()
	local self = CreateObject()

	-- 打开下面的注释可以看到同步对象在服务器中的位置
	local testPositionFlag = {}
	local showServerPos = function(uid, pos, rotation, t)
		-- print('pos:', pos.x, pos.y, pos.z)
		if not testPositionFlag[uid] or IsNil(testPositionFlag[uid]) then
			ResourceManager.CreateCharacter('Monster/hulijing',function(obj)
				testPositionFlag[uid] = obj
				if rotation then
					testPositionFlag[uid].transform.rotation = Quaternion.Euler(0, rotation, 0)
				end
				testPositionFlag[uid].transform.position = Vector3.New(pos.x, pos.y, pos.z)
				if t == 'stop' then
					testPositionFlag[uid].transform.localScale = Vector3.New(1, 0.5, 1)
				else
					testPositionFlag[uid].transform.localScale = Vector3.New(1, 1, 1)
				end
			end)
		end 
		
	end

	-- self.testAdd = function()
	-- 	local entityManager = SceneManager.GetEntityManager()
	-- 	local data = MyHeroManager.heroData
	-- 	local hero = SceneManager.GetEntityManager().hero
	-- 	hero.behavior:SetDefaultAnimation('NormalStandby')
	-- 	hero.behavior:SetModel(hero.behavior.soulPrefab, 1)	
	-- 	data.posX = hero:GetPosition().x
	-- 	data.posY = hero:GetPosition().y
	-- 	data.posZ = hero:GetPosition().z
	-- 	data.source = EntitySource.AOI
	-- 	Timer.Delay(2, function()
	-- 		entityManager.DestroyPuppet(data.entity_id)
	-- 		data.hp = 0
	-- 		Timer.Delay(0.01, function()
	-- 			entityManager.CreateHero(data)
	-- 		end)
	-- 	end)
	-- end
	
	local isPuppetSyncable = function(puppet)
		if not puppet or puppet:IsDestroy() or puppet:GetSyncPosition() then
			return false
		end
		if puppet.entityType == EntityType.Pet and puppet.data.owner_id == MyHeroManager.heroData.entity_id then
			return false
		end
		if puppet.uid == MyHeroManager.heroData.entity_id then
			return false
		end
		return true
	end
	-- self.OnEntityMove = function(uid, pos, speed, rotation, delaytime)
	-- 	if SceneManager.isSceneLoading then
	-- 		log('aoi', 'OnEntityMove failed! scene loading !')
	-- 		return
	-- 	end
	-- 	-- writeMsg('recv aoi move ' .. tostring(uid.Length))
	-- 	local entityManager = SceneManager.GetEntityManager()
	-- 	local puppet = entityManager.GetPuppet(uid)
	-- 	if isPuppetSyncable(puppet) then
	-- 		log('aoimove', '---- move uid=' .. puppet.uid, 
	-- 			'src:' .. string.format("(%.2f, %.2f, %.2f)",puppet:GetPosition().x, puppet:GetPosition().y, puppet:GetPosition().z),
	-- 			'server src:' .. string.format("(%.2f, %.2f, %.2f)", pos.x, pos.y, pos.z), 
	-- 			'speed:' .. speed, 
	-- 			'rotation:' .. rotation, 
	-- 			'delay:' .. delaytime)
	-- 		puppet:UpdateMoveto(pos, speed, rotation, delaytime)
	-- 		-- showServerPos(puppet.uid, pos, rotation, 'move')
	-- 	else
	-- 		log('aoimove', 'refuse move uid=' .. uid)
	-- 	end
	-- end

	-- self.OnEntityStopMove = function(uid, pos, rotation, speed, delaytime)
	-- 	if SceneManager.isSceneLoading then
	-- 		log('aoi', 'OnEntityStopMove failed! scene loading ! ')
	-- 		return
	-- 	end
	-- 	-- writeMsg('recv aoi stop move ' .. tostring(uid.Length))
	-- 	local entityManager = SceneManager.GetEntityManager()		
	-- 	for i = 0, uid.Length - 1, 1 do
	-- 		local puppet = entityManager.GetPuppet(uid[i])
	-- 		if isPuppetSyncable(puppet) then
	-- 			log('aoimove', '---- stop move uid=' .. puppet.uid, 
	-- 				'src:' .. string.format("(%.2f, %.2f, %.2f)",puppet:GetPosition().x, puppet:GetPosition().y, puppet:GetPosition().z),
	-- 				'stop pos:' .. string.format("(%.2f, %.2f, %.2f)", pos[i].x, pos[i].y, pos[i].z), 
	-- 				'rot:' .. string.format("%.2f", rotation[i]), 
	-- 				'speed:' .. speed[i], 
	-- 				'delay:' .. delaytime)
	-- 			puppet:StopAt(pos[i], rotation[i])
	-- 			-- puppet:StopMove()
	-- 			-- showServerPos(puppet.uid, pos[i], rotation[i], 'stop')
	-- 		else
	-- 			log('aoimove', 'refuse stopmove uid=' .. uid[i])
	-- 		end
	-- 	end
	-- end

	-- self.OnEntitySetPosition = function(uid, pos)
	-- 	if SceneManager.isSceneLoading then
	-- 		log('aoi', 'OnEntitySetPosition failed! scene loading ! uid=' .. uid)
	-- 		return
	-- 	end
	-- 	-- writeMsg('recv aoi set position ')
	-- 	local puppet = SceneManager.GetEntityManager().GetPuppet(uid)
	-- 	if isPuppetSyncable(puppet) then
	-- 		log('aoimove', '---- set position uid=' .. uid, string.format("(%.2f, %.2f, %.2f)", pos.x, pos.y, pos.z))
	-- 		puppet:SetPosition(pos)
	-- 	else
	-- 		log('aoimove', 'refuse set position uid=' .. uid)
	-- 	end		
	-- end

	-- self.OnEntitySetRotation = function(uid, pos, rotation)
	-- 	if SceneManager.isSceneLoading then
	-- 		log('aoi', 'OnEntitySetRotation failed! scene loading! uid=' .. uid)
	-- 		return
	-- 	end
	-- 	-- writeMsg('recv aoi set rotation ')
	-- 	local puppet = SceneManager.GetEntityManager().GetPuppet(uid)
	-- 	if isPuppetSyncable(puppet) then
	-- 		log("aoimove", '---- rotate uid:' .. puppet.uid, string.format("(%.2f, %.2f, %.2f)", pos.x, pos.y, pos.z), string.format("%.2f", rotation))
	-- 		puppet:SetRotation(Quaternion.Euler(0, rotation, 0))
	-- 	else
	-- 		log('aoimove', 'refuse rotate uid:' .. uid)
	-- 	end		
	-- end

	self.OnAOIDel = function(uid, sceneid)
		if SceneManager.isSceneLoading then
			log('aoi', 'OnAOIDel failed! scene loading!')
			return
		end
		local serverSceneid = SceneManager.GetCurServerSceneId()
		if serverSceneid ~= sceneid then
			log('aoi','aoi del failed! not this scene !' .. 'current:' .. serverSceneid .. ' aoi:' .. (sceneid or 'nil'))
			return
		end
		-- writeMsg('recv aoi delete ' .. tostring(uid.Length))
		local entityManager = SceneManager.GetEntityManager()
		for i = 0, uid.Length - 1, 1 do
			log('aoi','aoi delete uid=' .. uid[i])
			entityManager.DestroyPuppet(uid[i])
		end
	end

	self.OnAOIAdd = function(uid, pos, packdata, sceneid)
		if SceneManager.isSceneLoading then
			log('aoi', 'OnAOIAdd failed! scene loading!')
			return
		end
		local serverSceneid = SceneManager.GetCurServerSceneId()
		if serverSceneid ~= sceneid then
			log('aoi', 'aoi add failed! not this scene!' .. 'current:' .. serverSceneid .. ' aoi:' .. (sceneid or 'nil'))
			return
		end
		-- writeMsg('recn aoi add ' .. tostring(uid.Length))
		
		local entityManager = SceneManager.GetEntityManager()
		for i = 0, uid.Length - 1, 1 do
			local data = mp.unpack(packdata[i])
			data.entity_id = uid[i]
			data.posX = pos[i].x
			data.posY = pos[i].y
			data.posZ = pos[i].z
			data.source = EntitySource.AOI

			log('aoi', table.toString(data, '--- aoi add entityType='.. data.entity_type .. ' uid=' .. uid[i] .. '---'))
			if data.entity_type == EntityType.Dummy then	
				table.print(data, ' ***** OnAOIAdd ***** ishero:' .. tostring(uid[i] == MyHeroManager.heroData.entity_id))
				if uid[i] == MyHeroManager.heroData.entity_id then
					entityManager.CreateHero(data)
				else
					local dummy = entityManager.CreateDummy(data)			
					-- dummy:SetNavMesh(false)
				end
			elseif data.entity_type == EntityType.WildPet then
				data.Scale = data.Scale/100
				local unit = entityManager.CreateWildPet(data)
				-- unit:SetNavMesh(false)
			elseif data.entity_type == EntityType.Monster or 
				   data.entity_type == EntityType.MonsterCamp then
				data.Scale = data.Scale/100
				if data.entity_type == EntityType.Monster then
					unit = entityManager.CreateMonster(data)
				else
					unit = entityManager.CreateMonsterCamp(data)
				end
				-- unit:SetNavMesh(false)
			elseif data.entity_type == EntityType.Transport then
				data.Scale = data.Scale/100
				unit = entityManager.CreateTransport(data)
			elseif data.entity_type == EntityType.TransportGuard then
				data.Scale = data.Scale/100
				unit = entityManager.CreateTransportGuard(data)		
			elseif data.entity_type == EntityType.NPC then
				data.Scale = data.Scale/100
				unit = entityManager.CreateDungeonNPC(data)
				-- unit:SetNavMesh(false)
			elseif data.entity_type == EntityType.Pet then
				data.source = EntitySource.AOI
				local pet = entityManager.CreatePet(data)
				-- pet:SetNavMesh(false)
			elseif data.entity_type == EntityType.Drop then
				data.create_x = (data.create_x or 0)/ 100
				data.create_y = (data.create_y or 0)/ 100
				data.create_z = (data.create_z or 0)/ 100
				local drop = entityManager.CreateDrop(data)
				-- drop:SetNavMesh(false)
			elseif data.entity_type == EntityType.Barrier then
				entityManager.CreateBarrier(data)
			elseif data.entity_type == EntityType.ConveyTool then
				entityManager.CreateConveyTool(data)
			elseif data.entity_type == EntityType.Trick then
				entityManager.CreateTrick(data)
			elseif data.entity_type == EntityType.Summon then
				entityManager.CreateSummon(data)
			else
				error('没有添加该aoi类型 type=' .. data.entity_type)
			end
		end
	end

	return self
end

AOIManager = AOIManager or CreateAOIManager()