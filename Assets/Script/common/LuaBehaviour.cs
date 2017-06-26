using UnityEngine;
using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.UI;

public class LuaBehaviour : View
{
    public string FullPath;    // 注：lua文件名和表名必须一致！！
    public bool component = false;
    public LuaTable luaTable { get; private set; }

    public LuaFunction onMessage;

    protected void Awake()
    {
        if (luaTable == null)
        {
            if (!string.IsNullOrEmpty(FullPath))
            {
                LoadLuaScript(FullPath);
            }
        }
    }

    public void LoadLuaScript(string fullPath)
    {
        if (string.IsNullOrEmpty(fullPath))
        {
            return;
        }
        FullPath = fullPath;

        if (!component)
        {
            string className = System.IO.Path.GetFileNameWithoutExtension(FullPath);
            luaTable = LuaManager.GetTable(className);
            if (luaTable == null)
            {
                LuaManager.DoFile(FullPath);
                if (!string.IsNullOrEmpty(className))
                {
                    luaTable = LuaManager.GetTable(className);
                    if (luaTable == null)
                    {
                        Util.LogError("Game", string.Format("没有找到{0}对应的lua表, 请确保文件名和lua表名一致", className));
                    }
                }
            }
        }
        else
        {
            object[] luaRet = LuaManager.DoFile(FullPath);
            if (luaRet != null && luaRet.Length >= 1)
            {
                // 约定：第一个返回的Table对象作为Lua模块  
                luaTable = luaRet[0] as LuaTable;
            }
            else
            {
                Util.LogError("Game", "Lua脚本没有返回Table对象：" + FullPath);
            }
        }

        if (luaTable != null)
        {
            luaTable["transform"] = transform;
            luaTable["gameObject"] = gameObject;
        }
        Call("Awake");
    }

    protected void Start()
    {
        Call("Start");        
    }

    public override void OnMessage(IMessage message)
    {
        if (onMessage != null)
        {
            onMessage.Call(message);
        }
    }

    //protected void Update()
    //{
    //    Call("Update");
    //}

    //protected void FixedUpdate()
    //{
    //    Call("FixedUpdate");
    //}

    //protected void LateUpdate()
    //{
    //    Call("LateUpdate");
    //}    

    public void OnEnable()
    {
        Call("OnEnable");
    }
    public void OnDisable()
    {
        Call("OnDisable");
    }
    protected void OnDestroy()
    {
        //#if ASYNC_MODE
        //        string abName = name.ToLower().Replace("panel", "");
        //        ResManager.UnloadAssetBundle(abName + AppConst.ExtName);
        //#endif
        //Util.ClearMemory();
        
        Call("OnDestroy");
        if (luaTable != null)
        {
            luaTable.Dispose();
            luaTable = null;
        }
    }

    protected object[] Call(string func, params object[] pArgs)
    {
        if (luaTable != null)
        {
            return Util.CallMethod(luaTable, func, pArgs);
        }
        return null;        
    }
}
