/********************************************************************************
** auth： panyinglong
** date： 2011/05/11
** desc： 位置同步
*********************************************************************************/

using UnityEngine;
using System.Collections;
using System;

public class UpdatePosComp : MonoBehaviour
{
    public PuppetBehavior behavior;
    private Transform cacheTransform;

    public float adjustDis = 1.5f;

    // 同步位置
    public bool hasUpdateMove { get; private set; }
    public Vector3 updatePosition { get; private set; }
    public Vector3 updateForward { get; private set; }

    private float serverSpeed;

    // 位置调整
    public bool isAdjustMoving { get; private set; }
    public Vector3 adjustPosition { get; private set; }
    private float adjustSpeed = 0;
    void Awake()
    {
        cacheTransform = transform;
    }

    // Update is called once per frame
    void Update()
    {
        if (behavior.spurtComp.IsOnSpurt())
        {
            return;
        }
        if(isAdjustMoving)
        {
            OnAdjustMoving();
        }
        else if (hasUpdateMove)
        {
            OnMoving();
        }
    }
    public bool IsMoving
    {
        get
        {
            return hasUpdateMove || isAdjustMoving;
        }
    }
    public void StopMove()
    {
        hasUpdateMove = false;
    }

    public void StopAt(Vector3 pos, float rotation)
    {
        AdjustTo(pos, rotation, 0.2f);
    }

    // 调整位置
    void AdjustTo(Vector3 pos, float rotation, float adjustTime)
    {
        pos = samplePosition(pos);
        behavior.rotateComp.SetRotateAngle(rotation);
        behavior.StopMove();

        isAdjustMoving = true;

        adjustPosition = pos;

        Vector3 dir = adjustPosition - cacheTransform.position;
        adjustSpeed = dir.magnitude / adjustTime;
    }
    // 停到某个pos 
    void OnAdjustMoving()
    {
        Vector3 dir = adjustPosition - cacheTransform.position;
        dir.y = 0;
        Vector3 deltaDir = adjustSpeed * Time.deltaTime * dir.normalized;
        Vector3 nextPos = cacheTransform.position + deltaDir;
        //nextPos = samplePosition(nextPos);

        Vector3 dirAfter = adjustPosition - nextPos;
        dirAfter.y = 0;
        float dot = dir.x * dirAfter.x + dir.z * dirAfter.z;
        if (dot < 0 || dir.magnitude < 0.01f) // 到到目的地,多走一步就走过头了
        {
            cacheTransform.position = adjustPosition;
            isAdjustMoving = false;
        }
        else        // 还没有到终点
        {
            cacheTransform.position = nextPos;
        }
    }

    public void UpdateMoveto(Vector3 pos, float speed, float rotation, float delaytime)
    {
        pos = samplePosition(pos);
        isAdjustMoving = false;
        behavior.rotateComp.SetRotateAngle(rotation);

        Quaternion r = Quaternion.AngleAxis(rotation, Vector3.up);
        updateForward = r * Vector3.forward;

        float dis = Vector3.Distance(pos, cacheTransform.position);
        if (dis >= adjustDis)
        {
            Vector3 adjustPos = pos + updateForward.normalized * speed / 100 * delaytime / 1000;
            AdjustTo(adjustPos, rotation, 0.2f);
            updatePosition = adjustPos + updateForward.normalized;
        }
        else
        {
            updatePosition = pos + updateForward.normalized;
        }

        serverSpeed = speed;
        hasUpdateMove = true;
        
    }
    void OnMoving()
    {
        ////Util.Log("Game", "speed:" + behavior.Speed);
        Vector3 dir = updatePosition - cacheTransform.position;
        dir.y = 0;
        Vector3 deltaDir = (serverSpeed * behavior.logicSpeed / 100) * Time.deltaTime * dir.normalized;
        Vector3 nextPos = cacheTransform.position + deltaDir;
        nextPos = samplePosition(nextPos);
        cacheTransform.position = nextPos;

        Vector3 dirAfter = updatePosition - nextPos;
        dirAfter.y = 0;
        float dot = dir.x * dirAfter.x + dir.z * dirAfter.z;
        if (dot < 0 || dir.magnitude < 0.01f) // 到到目的地,多走一步就走过头了
        {
            behavior.Speed = serverSpeed;
            updatePosition = cacheTransform.position + updateForward.normalized;
        }
    }
    
    Vector3 samplePosition(Vector3 pos)
    {
        NavMeshHit hit;
        if (NavMesh.SamplePosition(pos, out hit, 20, NavMesh.AllAreas))
        {
            //Vector3 v = new Vector3(pos.x, hit.position.y, pos.z);
            //float disXZ = Mathf.Sqrt((pos.x - hit.position.x) * (pos.x - hit.position.x) + (pos.z - hit.position.z) * (pos.z - hit.position.z));
            //if (disXZ > 1)
            //{
            //    Util.Log("poserr", string.Format("xz距离矫正过大 disXZ:{2}, uid:{0}, entityType:{1}, src:{3}, adjust:{4}", behavior.uid, behavior.entityType, disXZ, pos.ToString(), hit.position.ToString()));
            //}
            //float disY = Math.Abs(pos.y - hit.position.y);
            //if (disY > 1)
            //{
            //    Util.Log("poserr", string.Format("y轴矫正过大 disY:{2}, uid:{0}, entityType:{1}, src:{3}, adjust:{4}", behavior.uid, behavior.entityType, disY, pos.ToString(), hit.position.ToString()));
            //}
            //return v;
            return hit.position;
        }
        return pos;
    }
}
