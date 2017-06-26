using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using System.Reflection;
using System.IO;


public class GameManager : Manager
{
    public bool IsGameStart = false;
    //---------------------------------------------------------
    bool created_ = false;
    
    // Lua模块
    private LuaModule lua_module_ = new LuaModule();

    // aoi模块
    private AOIModule aoi_module = new AOIModule();
    public CullingGroupLoadRes CullGroup { get; set; }
    //---------------------------------------------------------
    /// <summary>
    /// 热更完成，启动游戏
    /// </summary>

    void Update()
    {
        if (!IsGameStart)
        {
            return;
        }
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            ExitGameConfirm();
        }
            
        // 日志中心
        //LogCenter.Instance().Update();
        LoadSceneManager.Instance().Update();
        
        EntityBehaviorMgr.Instance().UpdateBehavior(Time.deltaTime);
    }

    void FixedUpdate ()
    {
        if (Time.frameCount % 5 == 0)
            ObjectPoolManager.Tick();
    }
    //------------------------------------------
    public void StartGame()
    {
        if (IsGameStart)
        {
            return;
        }

        if (!IsCreated)
        {
            Debug.Log("初始化GameManager");
            Create();
        }

        IsGameStart = true;
        CanSyncMsg = true;
    }
    public bool CanSyncMsg { get; set; }

    private float gameSpeed = 1;
    public float GameSpeed
    {
        get {
            return gameSpeed;
        }
        set
        {
            if(value < 0)
            {
                value = 0;
            }
            if(value > 10)
            {
                value = 10;
            }
            gameSpeed = value;
            EntityBehaviorMgr.Instance().SetEntityMgrSpeed(gameSpeed);
           // Time.timeScale = gameSpeed;
        }
    }

    bool ExitGameConfirm()
    {
        Application.Quit();
        return true;
    }
    
    // 获取Lua模块
    public LuaModule GetLuaModule()
    {
        return lua_module_;
    }

    public AOIModule GetAOIModule()
    {
        return aoi_module;
    }

    // 创建
    void Create()
    {
        if (IsCreated)
        {
            return;
        }
        IsCreated = true;

    }
    
    public bool IsCreated
    {
        get { return created_; }
        set { created_ = value; }
    }
    // 销毁
    public void Destroy()
    {
        //network_.Close();
    }
}
