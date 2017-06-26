/********************************************************************************
** auth： panyinglong
** date： 2017/05/11
** desc： 寻路
*********************************************************************************/

using UnityEngine;
using System;
using System.Collections.Generic;

public enum MoveType
{
    None = 0,
    Destination = 1,
    Direction = 2,
}

public class NavigationComp : MonoBehaviour
{    
    public PuppetBehavior behavior;
    private Transform cacheTransform;
    public float stoppingDistance;
    public float radius = 5;
    public float speed;

    List<Vector3> pathCorners = new List<Vector3>();
    private static readonly object obj = new object();

    public MoveType moveType { get; private set; }

    void Awake()
    {        
        cacheTransform = transform;
        moveType = MoveType.None;
    }

    // Update is called once per frame
    void Update()
    {
        if (behavior.spurtComp.IsOnSpurt())
        {
            return;
        }

        if(IsMoving)
        {
            OnMoving();
        }
    }
    
    public bool IsMoving
    {
        get
        {
            return pathCorners.Count > 0;
        }        
    }
    void OnMoving()
    {
        Vector3 nextCorner = pathCorners[0]; 
        Vector3 dir = nextCorner - cacheTransform.position;
        dir.y = 0;
        Vector3 deltaDir = (speed * behavior.logicSpeed / 100 * Time.deltaTime * dir.normalized);
        Vector3 nextPos = cacheTransform.position + deltaDir;
        nextPos = samplePosition(nextPos);
        Vector3 dirAfter = nextCorner - nextPos;
        dirAfter.y = 0;
        if(dir.magnitude > 0)
        {
            behavior.rotateComp.SetLookAt(nextCorner, true);
        }

        float dot = dir.x * dirAfter.x + dir.z * dirAfter.z;
        if (dot < 0 || dir.magnitude < 0.01f) // 多走一步就走过头了
        {
            cacheTransform.position = nextCorner;
            if (pathCorners.Count > 1) 
            {
                lock(obj)
                {
                    pathCorners.RemoveAt(0);
                }
            }
            else // 最后一个点了
            {
                StopMove();
            }
        }
        else        // 还没有到终点
        {
            cacheTransform.position = nextPos;
        }
        if (behavior.IsSyncPosition) // 同步到服务器
        {
            behavior.synComp.SyncMove(cacheTransform.position);
        }
    }
    public void SetPosition(Vector3 pos)
    {
        cacheTransform.position = samplePosition(pos);
        if (behavior.IsSyncPosition)
        {
            behavior.synComp.SyncSetPosition(cacheTransform.position);
        }
    }
  
    public void StopMove()
    {
        if (behavior.IsSyncPosition && IsMoving)
        {
            behavior.synComp.SyncStopMove(cacheTransform.position);
        }
        lock (obj)
        {
            pathCorners.Clear();
        }
        moveType = MoveType.None;
    }

    // 目的地导航
    public void SetDestination(Vector3 dst)
    {
        NavMeshPath path = new NavMeshPath();
        if (NavMesh.CalculatePath(cacheTransform.position, dst, NavMesh.AllAreas, path))
        {
            lock (obj)
            {
                pathCorners.Clear();
                pathCorners.AddRange(path.corners);
                pathCorners.RemoveAt(0); //移除第一个点, 即当前位置点
            }
            moveType = MoveType.Destination;
        }
        else
        {
            Util.Log("Game", "没有找到路径");
        }
    }
    // 方向导航
    public void SetDirection(Vector3 dir)
    {
        Vector3 syncDeltaVec = behavior.Speed * behavior.logicSpeed / 100 * 1 * dir.normalized; // 设一个1秒后的位置 
        Vector3 syncDest = cacheTransform.position + syncDeltaVec;
        syncDest = samplePosition(syncDest);
        lock (obj)
        {
            pathCorners.Clear();
            pathCorners.Add(syncDest);
        }
        moveType = MoveType.Direction;
    }

    Vector3 samplePosition(Vector3 pos)
    {
        NavMeshHit hit;
        if (NavMesh.SamplePosition(pos, out hit, 20, NavMesh.AllAreas))
        {
            //Vector3 v = new Vector3(pos.x, hit.position.y, pos.z);
            //float disXZ = Mathf.Sqrt((pos.x - hit.position.x) * (pos.x - hit.position.x) + (pos.z - hit.position.z) * (pos.z - hit.position.z));
            //if(disXZ > 1)
            //{
            //    Util.Log("poserr", string.Format("xz距离矫正过大 disXZ:{2}, uid:{0}, entityType:{1}, src:{3}, adjust:{4}", behavior.uid, behavior.entityType, disXZ, pos.ToString(), hit.position.ToString()));
            //}
            //float disY = Math.Abs(pos.y - hit.position.y);
            //if(disY > 1)
            //{
            //    Util.Log("poserr", string.Format("y轴矫正过大 disY:{2}, uid:{0}, entityType:{1}, src:{3}, adjust:{4}", behavior.uid, behavior.entityType, disY, pos.ToString(), hit.position.ToString()));
            //}
            //return v;
            return hit.position;
        }
        return pos;
    }
}
