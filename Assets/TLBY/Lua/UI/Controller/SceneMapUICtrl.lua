
local function CreateSceneMapCtrl()
	local self = CreateCtrlBase()

    local sceneTable = require'Logic/Scheme/common_scene'
    local dungeonTable = require'Logic/Scheme/challenge_main_dungeon'
    local areanTable = require'Logic/Scheme/challenge_arena'
    local teamDungeonTable = require'Logic/Scheme/challenge_team_dungeon'
    local DestinationEffect = require "Logic/Effect/DestinationEffect"
    local const = require "Common/constant"
    
    local map = nil
    local uiCamera = nil
    local timer = nil
    local npcFlags = {}
    local routePoints = {}
    local transportPos = {}
    local sceneData = nil
    local mapWidth = 0
    local mapHeight = 0
    
    local ShowWorldMap = function()
        self.close()
        UIManager.PushView(ViewAssets.WorldMapUI)
    end
    
    local ShowSwitchChannel = function()
        UIManager.PushView(ViewAssets.SwitchChannelUI)
    end
    
    local TransSceneToMap = function(posX,posZ) 
        local lengthX = sceneData.MaxX - sceneData.MinX
        local lengthZ = sceneData.MaxZ - sceneData.MinZ
        local x = (posX - sceneData.MinX)/lengthX
        local z = (posZ - sceneData.MinZ)/lengthZ
        return Vector2(mapWidth*z,mapHeight*(1-x))
    end

    local HideNPC = function()
        for i=#npcFlags,1,-1 do
            GameObject.Destroy(npcFlags[i])
            table.remove(npcFlags,i)
        end
        npcFlags = {}
    end
    
    local ShowNPC = function(showNPC)
        if sceneData == nil then return end
        HideNPC()
        local sceneObjectTable = SceneManager.GetCurSceneLayoutScheme()        
        if sceneObjectTable == nil then return end
        for k,v in pairs(sceneObjectTable) do
            if v.MapName ~= '' and (showNPC or v.Type ~= 2) then
                local npcFlag = GameObject.Instantiate(self.view.dotNPC)
                npcFlag:SetActive(true)
                table.insert(npcFlags,npcFlag)  
                npcFlag.transform:SetParent(map.transform,false)
                npcFlag:GetComponent('RectTransform').anchoredPosition = TransSceneToMap(v.PosX, v.PosZ)
                npcFlag:GetComponent('TextMeshProUGUI').text = (LuaUIUtil.SceneTypeToColor[v.Type] or '')..v.MapName
            end
        end
    end
    
    local HideRoutePoints = function()
        for i=#routePoints,1,-1 do
            GameObject.Destroy(routePoints[i])
            table.remove(routePoints,i)
        end
        routePoints = {}
    end
    
    local HideTransportPos = function()
        for i=#transportPos,1,-1 do
            GameObject.Destroy(transportPos[i])
            table.remove(transportPos,i)
        end
        transportPos = {}
    end
    
    local GetTerrainPos = function(dest)
        local ray = UnityEngine.Ray.New(Vector3.down,dest)
        local hits = UnityEngine.Physics.RaycastAll(ray)
        for i = 0, hits.Length - 1 do
                if 'TerrainGeometry' == hits[i].collider.gameObject.tag then
                    return hits[i].point
                end
        end
        return nil
    end
    
    local ShowRoutePoints = function(targetPos,corners)
        HideRoutePoints()
        
        for i=#corners,2,-1 do
            if Vector3.Distance(corners[i],corners[i-1]) < 2.5 then           
                table.remove(corners,i)
            end
        end
        
        for i=#corners,2,-1 do
            local v1 = corners[i]
            local v2 = corners[i-1]
            local distance = Vector3.Distance(v1,v2)
            local count = math.floor(distance/3.5 + 0.5)
            for j=1,count do
                table.insert(corners,i,(v1*j + v2*(count+1 - j))/(count+1))
            end
 
        end
        
        for i=1,#corners-1 do
            local routePoint = GameObject.Instantiate(self.view.dotRoute)
            routePoint:SetActive(true)
            table.insert(routePoints,routePoint)
            routePoint.transform:SetParent(self.view.routeDots.transform,false)
            routePoint:GetComponent('RectTransform').anchoredPosition = TransSceneToMap(corners[i].x,corners[i].z)
        end
    end
 
    local MapClick = function(event)
        if SceneManager.GetEntityManager().hero == nil then return end
        if sceneData == nil then return end
        local ret
        local position
        ret,position = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.view.imgMap.transform, 
            event.position, uiCamera, 1)
        local x = position.x / self.view.imgMap:GetComponent('RectTransform').sizeDelta.x + 0.5
        local y = position.y / self.view.imgMap:GetComponent('RectTransform').sizeDelta.y  + 0.5
        local lengthX = sceneData.MaxX - sceneData.MinX
        local lengthZ = sceneData.MaxZ - sceneData.MinZ
        local des = Vector3.New((1-y)*lengthX+sceneData.MinX, 1000, sceneData.MinZ+x*lengthZ)
        local targetPos = GetTerrainPos(des)
        local heroPos = SceneManager.GetEntityManager().hero.behavior.transform.position
        while targetPos  == nil do
            if Vector3.Distance(heroPos,Vector3.New(des.x,heroPos.y, des.z)) < 0.5 then
                break
            end
            des = Vector3.New((heroPos.x*0.2+ des.x*0.8),1000, (heroPos.z*0.2+des.z*0.8))
            targetPos = GetTerrainPos(des)

        end

        
        if targetPos and SceneManager.GetEntityManager().hero:CanMove() then
            self.view.rightPos:SetActive(true)
            self.view.rightPos:GetComponent('RectTransform').anchoredPosition = TransSceneToMap(targetPos.x,targetPos.z)
            DestinationEffect.Moveto(targetPos)
            if timer then Timer.Remove(timer)end
            timer = Timer.Delay(2, self.close, self)
            
            local corners = Util.GetCorners(SceneManager.GetEntityManager().hero:GetPosition(), targetPos)
            if corners then
                ShowRoutePoints(targetPos, corners:ToTable())
            else
                print('没有找到路径点')
            end
        end

    end
    
    local RefreshNPC = function()
        ShowNPC(self.view.btnNPC:GetComponent('Toggle').isOn)
    end

    local requstTime = 0
    local Update = function()
        local hero = SceneManager.GetEntityManager().hero
        if hero == nil then return end

        self.posText.text = string.format('%d线(%d, %d)', SceneLineManager.curLineId, hero:GetPosition().x, hero:GetPosition().z)
        self.view.dotOwn.transform.localEulerAngles = Vector3.New(0,0,-hero.behavior.transform.localEulerAngles.y)
        local lengthX = sceneData.MaxX - sceneData.MinX
        local lengthZ = sceneData.MaxZ - sceneData.MinZ
        local x = (hero.behavior.transform.localPosition.x - sceneData.MinX)/lengthX
        local z = (hero.behavior.transform.localPosition.z - sceneData.MinZ)/lengthZ
        self.dotOwnRect.anchoredPosition = TransSceneToMap(hero.behavior.transform.localPosition.x,hero.behavior.transform.localPosition.z)
        
        if MyHeroManager.campScore and SceneManager.currentSceneType == const.SCENE_TYPE.WILD then
            if requstTime > 3 then
                requstTime = 0
            end
            if requstTime == 0 then
                local data = {}
                data.func_name = 'on_get_transport_fleet_position'
                data.scene_id = SceneManager.currentSceneId
                MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data) 
            end
            requstTime = requstTime + UnityEngine.Time.deltaTime
        end
    end
    
    self.GetTransportFleetPositionRet = function(data)
        HideTransportPos()
        if not data.transport_fleet_pos then return end
        for k,v in pairs(data.transport_fleet_pos) do         
            local dot = GameObject.Instantiate(self.view.dotOtherPlayers)
            dot:SetActive(true)
            table.insert(transportPos,dot)  
            dot.transform:SetParent(map.transform,false)
            dot:GetComponent('RectTransform').anchoredPosition = TransSceneToMap(v.x/100,v.z/100)
        end
    end
    
	self.onLoad = function()
        uiCamera = CameraManager.uiCamera
        map = self.view.imgMap:GetComponent('Image')
        self.view.rightPos:SetActive(false)
        self.posText = self.view.pos:GetComponent('TextMeshProUGUI')
        self.dotOwnRect = self.view.dotOwn:GetComponent('RectTransform')
        local tableData = SceneManager.GetCurSceneData()
        sceneData = sceneTable.TotalScene[tableData.SceneID]     
        if sceneData == nil then return end
        map.overrideSprite = ResourceManager.LoadSprite('Map/'..sceneData.ResourceID)        
        mapWidth = 100/sceneData.MapScale*1524
        mapHeight = map.preferredHeight/map.preferredWidth*mapWidth
        map:GetComponent('RectTransform').sizeDelta = Vector2.New(mapWidth,mapHeight)
        
        self.AddClick(self.view.btnClose,self.close)
        self.AddClick(self.view.btnWorldMap,ShowWorldMap)
        self.AddClick(self.view.btnSwitchChannel,ShowSwitchChannel)
        self.AddClick(self.view.imgMap,MapClick)
        self.AddClick(self.view.btnNPC,RefreshNPC)
        
        self.view.sceneName:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(tableData,'Name')
        UpdateBeat:Add(Update,self)
        Update()
        local h = (self.view.dotOwn:GetComponent('RectTransform').anchoredPosition.x - 1524/2) / (mapWidth - 1524)
        if h >1 then h=1 end
        if h<0 then h=0 end
        local w = (self.view.dotOwn:GetComponent('RectTransform').anchoredPosition.y - 640/2) / (mapHeight - 640)
        if w >1 then w=1 end
        if w<0 then w=0 end
        self.view.scrollView:GetComponent('ScrollRect').horizontalNormalizedPosition = h
        self.view.scrollView:GetComponent('ScrollRect').verticalNormalizedPosition = w
        RefreshNPC()
        
        MessageRPCManager.AddUser(self, 'GetTransportFleetPositionRet')
	end
    
	self.onUnload = function()
        UpdateBeat:Remove(Update,self)
        HideNPC()
        HideRoutePoints()
        MessageRPCManager.RemoveUser(self, 'GetTransportFleetPositionRet')
        if timer then Timer.Remove(timer) timer = nil end
	end

	return self
end

return CreateSceneMapCtrl()