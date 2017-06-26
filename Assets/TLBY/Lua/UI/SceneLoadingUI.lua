local function CreateSceneLoadingUI()
	local self = CreateObject()
    local loginTable = require'Logic/Scheme/system_login_create'
    local sceneTable = require'Logic/Scheme/common_scene' 
    local const = require "Common/constant"
    
    local GetSceneData = function(id)
        local data = {}
        local totalWeight = 0
        local level = 1
        local passTime = 0
		local mapid = nil
        if MyHeroManager.heroData then
            level = MyHeroManager.heroData.level
        end
        for k,v in pairs(loginTable.Tips) do
            if v.SceneID == id and level >= v.MinLevel and level <=v.MaxLevel then
                table.insert(data,v)
                totalWeight = totalWeight + v.Weight
            end
        end

        local rand = 0
        if totalWeight > 0 then rand = math.random(totalWeight) end
        for k,v in pairs(data) do
            rand = rand - v.Weight
            if rand <= 0 then
                return v
            end
        end
        return nil
    end
    
	self.Awake = function()
		self.bg = self.transform:FindChild("@bg"):GetComponent('Image');
		self.slider = self.transform:FindChild("@slider"):GetComponent('Slider');
		self.tip = self.transform:FindChild("@tip"):GetComponent('TextMeshProUGUI');

	end
    
    self.OnDisable = function()
        UpdateBeat:Remove(self.Update, self)
    end
    
    self.OnEnable = function()
        UpdateBeat:Add(self.Update, self)
        passTime = 0
		mapid = nil
    end
    
    self.UpdateScene = function(id)
        if id == nil then
            self.tip.text = "加载资源中"
            return
        end
        mapid = id
        local data = GetSceneData(id)
        if data ~= nil then
            self.tip.text = LuaUIUtil.GetTextByID(data,'Description')
        else
            self.tip.text = "加载资源中"
        end 
        
        if sceneTable.TotalScene[id] then
            local data = sceneTable.TotalScene[id].loading           
            self.bg.overrideSprite = ResourceManager.LoadSprite('LoadingBg/'..data[math.random(#data)])
        end
    end
    
    
    self.Update = function()
        passTime = passTime + UnityEngine.Time.deltaTime
        self.slider.value = math.max(Util.GetLoadingProgress(),math.min(0.8,passTime/3))
		local bHideload = true
		  if Util.GetLoadingProgress() > 0.999 then
		    if mapid ~= nil and  SceneManager.GetEntityManager().hero == nil then bHideload = false end
			if bHideload then
			   UIManager.HideLoadingUI()
			   CameraManager.CameraController:Reset()

                if SceneManager.currentSceneType == const.SCENE_TYPE.ARENA then
                    SoundManager.PlayBGM('City/jingjichang')
                elseif SceneManager.currentSceneType == const.SCENE_TYPE.DUNGEON then
                    SoundManager.PlayBGM('Dungeon/tongyongfuben')
                elseif SceneManager.currentSceneType == const.SCENE_TYPE.TEAM_DUNGEON then
                    SoundManager.PlayBGM('Dungeon/tongyongfuben')
                elseif SceneManager.currentSceneType == const.SCENE_TYPE.TASK_DUNGEON then
                    SoundManager.PlayBGM('Dungeon/tongyongfuben')
                elseif SceneManager.currentSceneType == const.SCENE_TYPE.WILD then
                    SoundManager.PlayBGM('City/langyayw1')
                elseif SceneManager.currentSceneType == const.SCENE_TYPE.CITY then
                    SoundManager.PlayBGM('City/zhulucheng')
                elseif SceneManager.currentSceneType == const.SCENE_TYPE.FACTION then
                    SoundManager.PlayBGM('City/zhulucheng')
                else
                    SoundManager.PlayBGM('City/city')
                end
			end
		  end
    end
    
	return self
end
return CreateSceneLoadingUI();
