using System.IO;
using ProtoBuf;
using UnityEngine;
using LuaInterface;
using LuaMessage;
using System.Text;

public class AOIModule : INetMessageHandler
{    
    public void Handle(Connection con, int action, byte[] data)
    {
        MemoryStream ms = new MemoryStream(data);
        switch ((MESSAGE_OPCODE)action)
        {
            case MESSAGE_OPCODE.SERVER_MESSAGE_OPCODE_CREATE_ENTITY: // aoi create entity
                {
                    SC_CREATE_ENTITY message = Serializer.Deserialize<SC_CREATE_ENTITY>(ms);
                    int sceneid = (int)message.SceneID;
                    int count = message.EntitiesCreate.Count;
                    string[] uid = new string[count];
                    Vector3[] pos = new Vector3[count];
                    LuaByteBuffer[] info = new LuaByteBuffer[count];

                    //Util.Log("Game", "aoi add count:" + message.EntitiesCreate.Count + " bytes:" + ms.Length);
                    for (int i = 0; i < message.EntitiesCreate.Count; i++)
                    {
                        SC_CREATE_ENTITY.Entity entity = message.EntitiesCreate[i];
                        uid[i] = System.Text.Encoding.ASCII.GetString(entity.EntityID);
                        info[i] = new LuaByteBuffer(entity.EntityInfo);
                        pos[i] = new Vector3(entity.EntityPos.DestX, entity.EntityPos.DestY, entity.EntityPos.DestZ);
                    }
                    Util.CallMethod("AOIManager", "OnAOIAdd", uid, pos, info, sceneid);
                    break;
                }
            case MESSAGE_OPCODE.SERVER_MESSAGE_OPCODE_DESTROY_ENTITY: // soi destroy eneity
                {
                    SC_DESTROY_ENTITY message = Serializer.Deserialize<SC_DESTROY_ENTITY>(ms);
                    int sceneid = (int)message.SceneID;
                    string[] uid = new string[message.EntitiesDestroy.Count];
                    //Util.Log("Game", "aoi del count:" + message.EntitiesDestroy.Count + " bytes:" + ms.Length);
                    for (int i = 0; i < message.EntitiesDestroy.Count; i++)
                    {
                        uid[i] = System.Text.Encoding.ASCII.GetString(message.EntitiesDestroy[i]);
                    }
                    Util.CallMethod("AOIManager", "OnAOIDel", uid, sceneid);
                }
                break;
            case MESSAGE_OPCODE.SERVER_MESSAGE_OPCODE_MOVE:         // entity move
                {
                    SC_MOVE_SYNC message = Serializer.Deserialize<SC_MOVE_SYNC>(ms);
                    string uid = Encoding.ASCII.GetString(message.SyncPostion.entityid);
                    if (LoadSceneManager.Instance().Isloading())
                    {
                        Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_MOVE when scene is loading! sceneid={0} uid={1}", message.SceneID, uid));
                        break;
                    }
                    EntityBehavior entity = EntityBehaviorMgr.Instance().GetEntityBehavior(uid);
                    if (entity == null)
                    {
                        Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_MOVE not found entity! sceneid={0} uid={1}", message.SceneID, uid));
                        break;
                    }
                    if (entity is PuppetBehavior)
                    {
                        PuppetBehavior puppet = entity as PuppetBehavior;
                        if (puppet == null)
                        {
                            Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_MOVE entity is not puppet! sceneid={0} uid={1}", message.SceneID, uid));
                            break;
                        }
                        if (puppet.IsSyncPosition)
                        {
                            //Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_MOVE entity IsSyncPosition = true! sceneid={0} uid={1}", message.SceneID, uid));
                            break;
                        }
                        int delaytime = (int)(con.ServerTimestamp - (long)message.servertime);
                        if (delaytime <= 0)
                        {
                            delaytime = 0;
                        }
                        int sceneid = (int)message.SceneID;

                        Vector3 pos = new Vector3(message.SyncPostion.DestX, message.SyncPostion.DestY, message.SyncPostion.DestZ);
                        float speed = message.SyncPostion.Speed;
                        float rotation = message.SyncPostion.Orientation;
                        puppet.UpdateMoveto(pos, speed, rotation, delaytime);
                    }
                    else if (entity is ToyBehavior)
                    {
                        ToyBehavior puppet = entity as ToyBehavior;
                        if (puppet == null)
                        {
                            Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_MOVE entity is not toy! sceneid={0} uid={1}", message.SceneID, uid));
                            break;
                        }
                        Vector3 pos = new Vector3(message.SyncPostion.DestX, message.SyncPostion.DestY, message.SyncPostion.DestZ);
                        puppet.Moveto(pos);
                        //Debug.Log(string.Format("moveto speed:{0}, dest:{1}, rotation:{2}, uid:{3}", message.SyncPostion.Speed, pos.ToString(), message.SyncPostion.Orientation, uid));
                    }

                    //Util.CallMethod("AOIManager", "OnEntityMove", uid, pos, speed, rotation, delaytime);
                    break;
                }
            case MESSAGE_OPCODE.SERVER_MESSAGE_OPCODE_STOP_MOVE:        // entity stop move
                {
                    SC_STOP_MOVE_SYNC message = Serializer.Deserialize<SC_STOP_MOVE_SYNC>(ms);
                    if (LoadSceneManager.Instance().Isloading())
                    {
                        Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_STOP_MOVE when scene is loading! sceneid={0}", message.SceneID));
                        break;
                    }
                    int delaytime = (int)(con.ServerTimestamp - (long)message.servertime);
                    if (delaytime <= 0)
                    {
                        //Util.Log("Game", "SERVER_MESSAGE_OPCODE_STOP_MOVE delaytime <= 0 delaytime=" + delaytime);
                        delaytime = 0;
                        //break;
                    }
                    int count = message.SyncPostion.Count;
                    string uid;
                    Vector3 pos;
                    float rotation;
                    float speed;
                    for (int i = 0; i < message.SyncPostion.Count; i++)
                    {
                        Position p = message.SyncPostion[i];
                        uid = Encoding.ASCII.GetString(p.entityid);
                        pos = new Vector3(p.DestX, p.DestY, p.DestZ);
                        rotation = p.Orientation;
                        speed = p.Speed;

                        EntityBehavior entity = EntityBehaviorMgr.Instance().GetEntityBehavior(uid);
                        if (entity == null)
                        {
                            Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_STOP_MOVE not found entity! sceneid={0} uid={1}", message.SceneID, uid));
                            break;
                        }
                        if (entity is PuppetBehavior)
                        {
                            PuppetBehavior puppet = entity as PuppetBehavior;
                            if (puppet == null)
                            {
                                Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_STOP_MOVE entity is not puppet! sceneid={0} uid={1}", message.SceneID, uid));
                                break;
                            }
                            if (puppet.IsSyncPosition)
                            {
                                //Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_MOVE entity IsSyncPosition = true! sceneid={0} uid={1}", message.SceneID, uid));
                                break;
                            }
                            puppet.StopAt(pos, rotation);
                        }
                        else if (entity is ToyBehavior)
                        {
                            ToyBehavior puppet = entity as ToyBehavior;
                            if (puppet == null)
                            {
                                Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_STOP_MOVE entity is not toy! sceneid={0} uid={1}", message.SceneID, uid));
                                break;
                            }
                            puppet.StopMove();
                            //Debug.Log(string.Format("stopmove dest:{0}, rotation:{1}, uid:{2}", pos.ToString(), p.Orientation, uid));
                        }
                    }
                    //Util.CallMethod("AOIManager", "OnEntityStopMove", uid, pos, rotation, speed, delaytime);
                    break;
                }
            case MESSAGE_OPCODE.SERVER_MESSAGE_FORCE_POSITION:           // entity set position
                {
                    SC_FORCE_MOVE message = Serializer.Deserialize<SC_FORCE_MOVE>(ms);
                    string uid = Encoding.ASCII.GetString(message.entityid);
                    Vector3 pos = new Vector3(message.DestX, message.DestY, message.DestZ);
                    //Util.CallMethod("AOIManager", "OnEntitySetPosition", uid, pos);
                    if (LoadSceneManager.Instance().Isloading())
                    {
                        Util.Log("Game", string.Format("SERVER_MESSAGE_FORCE_POSITION when scene is loading! sceneid={0} uid={1}", message.SceneID, uid));
                        break;
                    }
                    EntityBehavior entity = EntityBehaviorMgr.Instance().GetEntityBehavior(uid);
                    if (entity == null)
                    {
                        Util.Log("Game", string.Format("SERVER_MESSAGE_FORCE_POSITION not found entity! sceneid={0} uid={1}", message.SceneID, uid));
                        break;
                    }
                    if (entity is PuppetBehavior)
                    {
                        PuppetBehavior puppet = entity as PuppetBehavior;
                        if (puppet == null)
                        {
                            Util.Log("Game", string.Format("SERVER_MESSAGE_FORCE_POSITION entity is not puppet! sceneid={0} uid={1}", message.SceneID, uid));
                            break;
                        }
                        if (puppet.IsSyncPosition)
                        {
                            //Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_MOVE entity IsSyncPosition = true! sceneid={0} uid={1}", message.SceneID, uid));
                            break;
                        }
                        puppet.SetPosition(pos);
                    }
                    else if (entity is ToyBehavior)
                    {
                        ToyBehavior puppet = entity as ToyBehavior;
                        if (puppet == null)
                        {
                            Util.Log("Game", string.Format("SERVER_MESSAGE_FORCE_POSITION entity is not toy! sceneid={0} uid={1}", message.SceneID, uid));
                            break;
                        }
                        puppet.SetPosition(pos);
                    }

                    break;
                }
            case MESSAGE_OPCODE.SERVER_MESSAGE_OPCODE_TURN_DIRECTION:   // entity set rotation
                {
                    SC_TURN_DIRECTION message = Serializer.Deserialize<SC_TURN_DIRECTION>(ms);
                    string uid = Encoding.ASCII.GetString(message.entityid);
                    Vector3 pos = new Vector3(message.DestX, message.DestY, message.DestZ);
                    //Util.CallMethod("AOIManager", "OnEntitySetRotation", uid, pos, message.Direction);
                    if (LoadSceneManager.Instance().Isloading())
                    {
                        Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_TURN_DIRECTION when scene is loading! sceneid={0} uid={1}", message.SceneID, uid));
                        break;
                    }
                    EntityBehavior entity = EntityBehaviorMgr.Instance().GetEntityBehavior(uid);
                    if (entity == null)
                    {
                        Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_TURN_DIRECTION not found entity! sceneid={0} uid={1}", message.SceneID, uid));
                        break;
                    }
                    if (entity is PuppetBehavior)
                    {
                        PuppetBehavior puppet = entity as PuppetBehavior;
                        if (puppet == null)
                        {
                            Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_TURN_DIRECTION entity is not puppet! sceneid={0} uid={1}", message.SceneID, uid));
                            break;
                        }
                        if (puppet.IsSyncPosition)
                        {
                            //Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_MOVE entity IsSyncPosition = true! sceneid={0} uid={1}", message.SceneID, uid));
                            break;
                        }
                        puppet.SetRotation(Quaternion.Euler(0, message.Direction, 0));
                    }
                    else if (entity is ToyBehavior)
                    {
                        ToyBehavior puppet = entity as ToyBehavior;
                        if (puppet == null)
                        {
                            Util.Log("Game", string.Format("SERVER_MESSAGE_OPCODE_TURN_DIRECTION entity is not toy! sceneid={0} uid={1}", message.SceneID, uid));
                            break;
                        }
                        puppet.SetRotation(Quaternion.Euler(0, message.Direction, 0));
                    }

                    break;
                }
        }
    }
}
