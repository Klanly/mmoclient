using UnityEngine;
using System.IO;
using ProtoBuf;
using LuaMessage;
using System.Text;

public class SynComp : MonoBehaviour
{
    private PuppetBehavior behavior = null;
    private Transform cacheTransform = null;

    private float lastAngle = 0f;
    private Vector3 lastSetPos = Vector3.zero;
    private float curSyncMoveTime = 0;
    private float curSyncRotateTime = 0;
    private float curSyncMoveDirTime = 0;
    private float curSyncMoveDirForceTime = 0;

    // 同步的上传频率
    private const float syncMoveForceTime = 2f;
    private const float syncMoveDirTime = 0.1f;
    private const float syncRotateTime = 0.5f;
    private const float syncMoveDirForceTime = 2f;

    private bool isStopState = true;

    GameManager gameMgr;
    void Awake()
    {
        if(behavior == null)
        {
            behavior = gameObject.GetComponent<PuppetBehavior>();            
        }
        cacheTransform = transform;
        gameMgr = AppFacade.Instance.gameManager;
    }
    void Update()
    {
        curSyncMoveTime += Time.deltaTime;
        curSyncRotateTime += Time.deltaTime;
        curSyncMoveDirTime += Time.deltaTime;
        curSyncMoveDirForceTime += Time.deltaTime;
    }
    Connection GetConnection()
    {
        if(AppFacade.Instance.networkManager.FightConnection.state == ConnectState.Success)
        {
            return AppFacade.Instance.networkManager.FightConnection;
        }
        return AppFacade.Instance.networkManager.MainConnection;
    }

    
    private void syncMove(Vector3 pos)
    {
        CS_CLIENT_MOVE message = new CS_CLIENT_MOVE();
        message.MyPostion = new Position()
        {
            DestX = pos.x,
            DestY = pos.y,
            DestZ = pos.z,
            entityid = Encoding.UTF8.GetBytes(behavior.uid),
            Orientation = behavior.rotateComp.rotationY,
            Speed = behavior.Speed
        };
        message.clienttime = (ulong)AppFacade.Instance.networkManager.GetConnection().GetTimestamp();
        message.SceneID = behavior.sceneid;

        MemoryStream ms = new MemoryStream();
        Serializer.Serialize<CS_CLIENT_MOVE>(ms, message);

        GetConnection().Send((int)MESSAGE_OPCODE.CLIENT_MESSAGE_OPCODE_MOVE, ms.ToArray());

        //Debug.Log("send msg move at " + pos.ToString() + " uid = " + behavior.uid + " orien:" + behavior.rotateComp.rotationY);
    }
    public void SyncMove(Vector3 pos)
    {
        if (!gameMgr.CanSyncMsg)
        {
            Debug.Log("此期间不可发送CLIENT_MESSAGE_OPCODE_MOVE消息");
            return;
        }
        if (behavior.navigationComp.moveType == MoveType.Destination)
        {
            if ((Mathf.Abs(behavior.rotateComp.rotationY - lastAngle) > 1) || curSyncMoveTime >= syncMoveForceTime || isStopState) // 有转向或者时间到了同步一次
            {
                syncMove(pos);
                lastAngle = behavior.rotateComp.rotationY;
                curSyncMoveTime = 0;
            }
        }
        else if (behavior.navigationComp.moveType == MoveType.Direction)
        {
            if ((Mathf.Abs(behavior.rotateComp.rotationY - lastAngle) > 1 && curSyncMoveDirTime >= syncMoveDirTime) || curSyncMoveDirForceTime >= syncMoveDirForceTime || isStopState)
            {
                syncMove(pos);
                curSyncMoveDirTime = 0;
                curSyncMoveDirForceTime = 0;
                lastAngle = behavior.rotateComp.rotationY;
            }
        }
        isStopState = false;
    }

    // 同步位置 
    public void SyncStopMove(Vector3 des)
    {
        isStopState = true;
        if (!gameMgr.CanSyncMsg)
        {
            Debug.Log("此期间不可发送CLIENT_MESSAGE_OPCODE_STOP_MOVE消息");
            return;
        }
        curSyncMoveTime = 0;
        
        CS_STOP_MOVE message = new CS_STOP_MOVE();
        message.MyPostion = new Position()
        {
            DestX = des.x,
            DestY = des.y,
            DestZ = des.z,
            entityid = Encoding.UTF8.GetBytes(behavior.uid),
            Orientation = behavior.rotateComp.rotationY,
            Speed = behavior.Speed
        };
        message.clienttime = (ulong)AppFacade.Instance.networkManager.GetConnection().GetTimestamp();
        message.SceneID = behavior.sceneid;

        MemoryStream ms = new MemoryStream();
        Serializer.Serialize<CS_STOP_MOVE>(ms, message);

        GetConnection().Send((int)MESSAGE_OPCODE.CLIENT_MESSAGE_OPCODE_STOP_MOVE, ms.ToArray());
        //Debug.Log("send msg stop move at " + des.ToString() + " uid = " + behavior.uid + " orien:" + cacheTransform.rotation.eulerAngles.y);
    }

    public void SyncSetPosition(Vector3 des)
    {
        if (!gameMgr.CanSyncMsg)
        {
            Debug.Log("此期间不可发送CLIENT_MESSAGE_FORCE_POSITION消息");
            return;
        }
        if (lastSetPos != Vector3.zero && Vector3.Distance(des, lastSetPos) < 0.1f)
        {
            return;
        }
        lastSetPos = des;

        CS_FORCE_MOVE message = new CS_FORCE_MOVE();
        message.entityid = Encoding.UTF8.GetBytes(behavior.uid);
        message.DestX = des.x;
        message.DestY = des.y;
        message.DestZ = des.z;
        message.SceneID = behavior.sceneid;

        MemoryStream ms = new MemoryStream();
        Serializer.Serialize<CS_FORCE_MOVE>(ms, message);

        GetConnection().Send((int)MESSAGE_OPCODE.CLIENT_MESSAGE_FORCE_POSITION, ms.ToArray());
        //Debug.Log("send msg set position " + des.ToString() + " uid = " + behavior.uid);
    }
    public void SyncSetRotation(Vector3 des, float y)
    {
        if (!gameMgr.CanSyncMsg)
        {
            Debug.Log("此期间不可发送CS_TURN_DIRECTION消息");
            return;
        }

        if (curSyncRotateTime <= syncRotateTime)
        {
            return;
        }
        curSyncRotateTime = 0;

        CS_TURN_DIRECTION message = new CS_TURN_DIRECTION();
        message.entityid = Encoding.UTF8.GetBytes(behavior.uid);
        message.DestX = des.x;
        message.DestY = des.y;
        message.DestZ = des.z;
        message.Direction = y;
        message.SceneID = behavior.sceneid;

        MemoryStream ms = new MemoryStream();
        Serializer.Serialize<CS_TURN_DIRECTION>(ms, message);

        GetConnection().Send((int)MESSAGE_OPCODE.CLIENT_MESSAGE_OPCODE_TURN_DIRECTION, ms.ToArray());
        //Debug.Log("send msg set rotation " + des.ToString() + " uid = " + behavior.uid + " direction:" + eulerAngles.y);
    }
}
