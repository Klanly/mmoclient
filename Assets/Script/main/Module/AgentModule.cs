/********************************************************************
	purpose:	网关服模块（心跳），实现
*********************************************************************/
using System;
using System.IO;
using UnityEngine;
using ProtoBuf;
public class AgentModule : INetMessageHandler
{
    TimerInfo sync_time_timer_ = null;
    // 重连定时器
    TimerInfo reconnect_timer_ = null;
    
    // 网络消息处理接口
    public void Handle(Connection con, int action, byte[] data)
    {
        //switch ((AgentMessage.MSG_CLIENTAGENT_ACTIONID)action)
        //{
        //    // 心跳，兼时间同步
        //    case AgentMessage.MSG_CLIENTAGENT_ACTIONID.MSG_CLIENTAGENT_CLIENTHEARTBEAT:
        //        {
        //            MemoryStream ms = new MemoryStream(data);
        //            AgentMessage.AC_AGENT_HeartBeat message = Serializer.Deserialize<AgentMessage.AC_AGENT_HeartBeat>(ms);
        //            AppFacade.Instance.gameManager.SetServerTime(message.ServerTime);
        //            // 重连监听定时器重置
        //            if (reconnect_timer_ != null)
        //            {
        //                reconnect_timer_.Reset();
        //            }                    
        //        }
        //        break;
        //    default:
        //        break;
        //}
    }
    //  指定时间间隔发送心跳包
    public void BeginSyncTime()
    {
        ////  心跳定时器
        //if (sync_time_timer_ == null)
        //{
        //    sync_time_timer_ = new TimerInfo(5, 0, delegate () {
        //        SendHeartBeatMessage();
        //    });
        //    AppFacade.Instance.timerManager.AddTimerEvent(sync_time_timer_);
        //}
        //// 重连定时器
        //if (reconnect_timer_ == null)
        //{
        //    reconnect_timer_ = new TimerInfo(20, 1, delegate () {
        //        Reconnect();
        //    });
        //    AppFacade.Instance.timerManager.AddTimerEvent(reconnect_timer_);
        //}
    }
    void Reconnect()
    {
        //AppFacade.Instance.gameManager.OnRequestReconnect();
    }
    public void SendHeartBeatMessage()
    {
        //AgentMessage.CA_AGENT_HeartBeat message = new AgentMessage.CA_AGENT_HeartBeat();
        //MemoryStream ms = new MemoryStream();
        //Serializer.Serialize<AgentMessage.CA_AGENT_HeartBeat>(ms, message);
        //AppFacade.Instance.networkManager.Send((int)MSG_ACTION.MSG_ACTION_HART,
        //                    ms.ToArray());
    }    
}