/********************************************************************
	purpose:	Lua模块
*********************************************************************/

using System;
using System.Collections.Generic;
using System.IO;
using ProtoBuf;
using UnityEngine;
using LuaInterface;
using LuaMessage;
using System.Text;

public class LuaModule : INetMessageHandler
{
    public int recvCount { get; private set; }
    public int sendCount { get; private set; }
        
    // 网络消息处理接口
    public void Handle(Connection con, int action, byte[] data)
    {
        recvCount++;
        MemoryStream ms = new MemoryStream(data);
        switch ((MESSAGE_OPCODE)action)
        {
            case MESSAGE_OPCODE.SERVER_MESSAGE_OPCODE_LUA_MESSAGE: // lua message
                {
                    SC_Lua_RunRequest message = Serializer.Deserialize<SC_Lua_RunRequest>(ms);
                    //long start = con.GetTimestamp();
                    Util.CallMethod("MessageManager", "OnLuaMessage", message.opcode, new LuaByteBuffer(message.parameters));
                    //long costtime = con.GetTimestamp() - start;
                    //if(costtime >= 10)
                    //{
                    //    Debug.Log(string.Format("message cost opcode:{0}, bytecount:{1}, milsec:{2}", message.opcode, message.parameters.Length, costtime));
                    //}
                    break;
                }
        }
    }

	public void RunLuaRequest(uint opcode, byte[] data, Connection con)
    {
        sendCount++;
        CS_Lua_RunRequest message = new CS_Lua_RunRequest();
        message.opcode = opcode;
        message.parameters = data;
        MemoryStream ms = new MemoryStream();
        Serializer.Serialize<CS_Lua_RunRequest>(ms, message);
        
        con.Send((int)MESSAGE_OPCODE.CLIENT_MESSAGE_LUA_MESSAGE, ms.ToArray());
    } 
}
