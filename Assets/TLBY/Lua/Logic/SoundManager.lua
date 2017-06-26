-- huasong --
require "Common/basic/LuaObject"

local function CreateSoundManager()
    local self = CreateObject()
    local bgm = gameMgr.gameObject.Find("BackgroundMusic"):GetComponent("AudioSource")
    local volume = UnityEngine.PlayerPrefs.GetFloat('Volume', 0.5)
    local audioEffect = UnityEngine.PlayerPrefs.GetInt('AudioEffect', 1)
    local backGroundMusic = UnityEngine.PlayerPrefs.GetInt('BackGroundMusic', 1)
    
    local SetAllSoundEffect = function(volume)
    	local puppets = SceneManager.GetEntityManager().QueryPuppets(function() return true end)
		for k, v in pairs(puppets) do
            if v.behavior and v.behavior.behavior and v.behavior.behavior.gameObject:GetComponent('PuppetBehavior') then
                v.behavior.behavior.audioSource.volume = volume
            end
		end
    end
    
    self.GetBgmOn = function()
        if backGroundMusic ==1 then return true end
        return false
    end
    
    self.SwitchBgm = function(value)
        if value then
            backGroundMusic = 1
        else
            backGroundMusic = 0
        end
        bgm.volume = math.min(volume,backGroundMusic)
        UnityEngine.PlayerPrefs.SetInt('BackGroundMusic', backGroundMusic)
    end
    
    self.GetVolume = function()
        return volume
    end
    
    self.GetBgmVolume = function()
        return math.min(volume,backGroundMusic)
    end
    
    self.GetAudioEffectVolume = function()
        return math.min(volume,audioEffect)
    end
    
    self.SetVolume = function(value)
        volume = value
        UnityEngine.PlayerPrefs.SetInt('Volume', volume)
        bgm.volume = self.GetBgmVolume()
        SetAllSoundEffect(self.GetAudioEffectVolume())
    end
    
    self.GetAudioEffectOn = function()
        if audioEffect ==1 then return true end
        return false
    end
    
    self.SwitchAudioEffect = function(value)
        if value then
            audioEffect = 1
        else
            audioEffect = 0
        end
        UnityEngine.PlayerPrefs.SetInt('AudioEffect', audioEffect)
        SetAllSoundEffect(math.min(volume,audioEffect))
    end
    
    self.PlayBGM = function(clipName)
        bgm.clip = ResourceManager.LoadAudioClip(clipName)
        bgm.loop = true
        bgm.pitch = 1
        bgm.volume = math.min(volume,backGroundMusic)
        bgm.playOnAwake = true
        bgm:Play()
    end
    
    self.PauseBGM = function()
        bgm:Pause()
    end
    
    self.StopBGM = function()
        bgm:Stop()
    end
    
    self.RepalyBGM = function()
        bgm:Play()
    end
    
    self.ResumeBGM = function()
        bgm:UnPause()
    end
    
    return self
end
SoundManager = SoundManager or CreateSoundManager()