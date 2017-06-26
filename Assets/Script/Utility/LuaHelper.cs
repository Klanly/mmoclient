using UnityEngine;
using System.Collections.Generic;
using System.Reflection;
using LuaInterface;
using System;

public static class LuaHelper
{

    /// <summary>
    /// getType
    /// </summary>
    /// <param name="classname"></param>
    /// <returns></returns>
    public static System.Type GetType(string classname)
    {
        Assembly assb = Assembly.GetExecutingAssembly();  //.GetExecutingAssembly();
        System.Type t = null;
        t = assb.GetType(classname); ;
        if (t == null)
        {
            t = assb.GetType(classname);
        }
        return t;
    }

  
    /// <summary>
    /// 资源管理器
    /// </summary>
    public static ResourceManager GetResManager()
    {
        return AppFacade.Instance.GetManager<ResourceManager>(ManagerName.Resource);
    }

    /// <summary>
    /// 网络管理器
    /// </summary>
    public static NetworkManager GetNetManager()
    {
        return AppFacade.Instance.GetManager<NetworkManager>(ManagerName.Network);
    }

    public static GameManager GetGameManager()
    {
        return AppFacade.Instance.GetManager<GameManager>(ManagerName.Game);
    }

    public static TimerManager GetTimerManager()
    {
        return AppFacade.Instance.GetManager<TimerManager>(ManagerName.Timer);
    }

    //public static ObjectPoolManager GetObjectPoolManager()
    //{
    //    return AppFacade.Instance.GetManager<ObjectPoolManager>(ManagerName.ObjectPool);
    //}

    /// <summary>
    /// pbc/pblua函数回调
    /// </summary>
    /// <param name="func"></param>
    public static void OnCallLuaFunc(LuaByteBuffer data, LuaFunction func)
    {
        if (func != null) func.Call(data);
        Debug.LogWarning("OnCallLuaFunc length:>>" + data.buffer.Length);
    }

    /// <summary>
    /// cjson函数回调
    /// </summary>
    /// <param name="data"></param>
    /// <param name="func"></param>
    public static void OnJsonCallFunc(string data, LuaFunction func)
    {
        Debug.LogWarning("OnJsonCallback data:>>" + data + " lenght:>>" + data.Length);
        if (func != null) func.Call(data);
    }
}


