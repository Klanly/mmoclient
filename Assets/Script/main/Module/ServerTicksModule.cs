///********************************************************************
//	purpose:	客户与服务器同步时间戳
//*********************************************************************/
//using System;
//using System.IO;
//using UnityEngine;
//using ProtoBuf;
//using LuaMessage;

//public class ServerTicksModule : INetMessageHandler
//{
//    public long deltaTime { get { return getCon().heartBeat.deltaTime; } }
//    public long delayTime { get { return getCon().heartBeat.delayTime; } }
    
//    public long ServerTimestamp { get { return getCon().heartBeat.ServerTimestamp; } }

//    public uint ServerSecondTimestamp { get{ return (uint)(ServerTimestamp / 1000);} }
//    public long GetSecondTimestamp()
//    {
//        return (GetTimestamp() / 1000);
//    }
//    public long GetTimestamp()
//    {
//        return getCon().heartBeat.GetTimestamp();
//    }
//    public string GetTimestampStr()
//    {
//        return GetTimestamp().ToString();
//    }

//    // 计算从现在到服务器的servertime需要多少毫秒
//    public long GetTimespan(long servertime)
//    {
//        long span = servertime - ServerTimestamp;
//        return span;
//    }
//    public int GetTimespanSeconds(uint serverSecondsTime)
//    {
//        return (int)(serverSecondsTime - ServerSecondTimestamp);
//    }
//    // 网络消息处理接口
//    public void Handle(int action, byte[] data)
//    {
        
//    }
//    Connection getCon()
//    {
//        if(AppFacade.Instance.networkManager.FightConnection.state == ConnectState.Success)
//        {
//            return AppFacade.Instance.networkManager.FightConnection;
//        }
//        else
//        {
//            return AppFacade.Instance.networkManager.MainConnection;
//        }
//    }
//}