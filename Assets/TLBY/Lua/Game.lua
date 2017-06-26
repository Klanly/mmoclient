--ZBS = "D:/tools/ZeroBraneStudio/";
--LuaPath = "D:/workspace/client/Assets/TLBY/Lua"
--package.path = package.path..";./?.lua;"..ZBS.."lualibs/?/?.lua;"..ZBS.."lualibs/?.lua;"..LuaPath.."?.lua;"
--package.cpath = package.cpath..ZBS.."bin/?.dll;"..ZBS.."bin/clibs/?.dll;"

--_G.debug = require('debug')
--require("mobdebug").start()

GRunOnClient = true
--管理器--
resMgr = LuaHelper.GetResManager();
networkMgr = LuaHelper.GetNetManager();
-- viewMgr = LuaHelper.GetViewManager();
gameMgr = LuaHelper.GetGameManager();

WWW = UnityEngine.WWW;
GameObject = UnityEngine.GameObject;

require "Network/MessageManager"
require "Model/Schemes"
require "Logic/SceneManager"
require "Logic/SceneLineManager"
require "Logic/DropManager"
require "Common/basic/functions"
require "Logic/Bag/BagManager"
require "Logic/GoldenFingerManager"
require "Logic/EnergyManager"
require "Logic/MainDungeonManager"
require "Logic/MyHeroManager"
require "Logic/ArenaManager"
require "Logic/TeamDungeonManager"
require "UI/UIManager"
require "UI/UISwitchManager"
require "UI/ChatManager"
require "UI/ContactManager"
require 'UI/GemManager'
require "Logic/TargetManager"
require "Logic/PKManager"
require "Logic/TeamManager"
require "Logic/CameraManager"
require "Logic/GlobalManager"
require "Logic/GameDisplayManager"
-- require "Logic/FightManager"
require "Logic/SoundManager"
require "Logic/FactionManager"
require "Logic/TaskManager"
require 'Logic/EntityBehaviorManager'
require 'Logic/ConnectionManager'

local log = require "basic/log"

CommonDefine = require("Common/constant")

local function CreateGame()
	local self = CreateObject()

	self.deviceId = Util.GetDeviceId()
    print('device_id=' .. self.deviceId)

	self.OnInitOK = function()
		print("---- lua Game OnInitOK ----");

	    gameMgr:StartGame();
		UIManager.LoadView(ViewAssets.LoginPanelUI)
        SoundManager.PlayBGM('City/city')
	end

	self.SetGameSpeed = function(duration, speed,callback)
		local defaultSpeed = gameMgr.GameSpeed
		gameMgr.GameSpeed = speed
		local t = Timer.Delay(duration , function()
			gameMgr.GameSpeed = defaultSpeed
			if callback then
				callback()
			end
		end)
		t.isAbs = true
	end

	-- 设置是否可以发送单同步消息 
	self.SetCanSyncMsg = function(b)
		gameMgr.CanSyncMsg = b
	end

	return self
end

math.randomseed(os.time())

Game = Game or CreateGame()

Game.GetServerList = function()
    local file = io.open(Util.GetLocalServerList(), "r")
    local str = file:read("*all")
    file:close()
    if not file then
        return nil
    end
    assert(file)
    local json = require "cjson"
    local t = json.decode(str)
    local list = {}
    for k,v in pairs(t) do
        local data = {}
        local index = math.random(1,#v)
        data.name = v[index].server_name
        data.ip = v[index].ip
        data.port = v[index].port
        data.new = v[index].new == 1
        table.insert(list,data)
    end
	return list
end
