/********************************************************************************
** auth： panyinglong
** date： 2016/1/5
** desc： 冲刺
*********************************************************************************/

using UnityEngine;
using System.Collections;
using System;

public class SpurtComp : MonoBehaviour
{
    private Transform cacheTransform;
    public PuppetBehavior behavior;

    float beforeTime = 0;
    float afterTime = 0;
    float spurtTime = 0;
    float currentTime = 0;
    float spurtSpeed = 0;
    float beforeSpeed = 0;
    float afterSpeed = 0;
    Vector3 spurtDir = Vector3.zero;
    bool visibleOnSpurt = true;
    bool stopFrameOnSpurt = true;
    Vector3 motion;

    void Awake()
    {
        cacheTransform = transform;
    }
    void SyncPosition()
    {
        behavior.synComp.SyncSetPosition(cacheTransform.position);
    }

    // Update is called once per frame
    void Update()
    {
        if (IsOnSpurt())    //冲刺
        {
            OnSpurt();
        }
    }
    
    public void OnKnockBarrier(BoxCollider b)
    {
        if (IsOnSpurt())
        {
            cacheTransform.position = cacheTransform.position - motion * 2;
            StopSpurt();
        }
    }

    public void SetSpurt(Vector3 dir, float speed, float bTime, float spuTime, float aTime, bool visible = true, float bSpeed = 0, float aSpeed = 0, bool stopFrame = true)
    {
        spurtDir = dir;
        beforeTime = bTime;
        afterTime = aTime;
        spurtTime = spuTime;
        spurtSpeed = speed;
        beforeSpeed = bSpeed;
        afterSpeed = aSpeed;
        currentTime = 0;
        visibleOnSpurt = visible;
        stopFrameOnSpurt = stopFrame;
    }
    void OnSpurt()
    {
        behavior.transform.forward = spurtDir;
        currentTime += Time.deltaTime;
        if (currentTime < beforeTime)      // 前摇
        {
            if (beforeSpeed > 0)
            {
                motion = beforeSpeed * behavior.logicSpeed * Time.deltaTime * spurtDir;
                cacheTransform.position = samplePosition(cacheTransform.position + motion);
                //characterController.Move(motion);
            }
        }
        else if (currentTime < (beforeTime + spurtTime))// 冲刺
        {
            if (visibleOnSpurt == false)
            {
                behavior.Visible = false;
            }
            if (stopFrameOnSpurt)
            {
                behavior.SetCurrentAnimationSpeed(0);
            }
            motion = spurtSpeed * behavior.logicSpeed * Time.deltaTime * spurtDir;
            cacheTransform.position = samplePosition(cacheTransform.position + motion);
            //characterController.Move(motion);
        }
        else if (currentTime < (beforeTime + spurtTime + afterTime))
        {
            if (afterSpeed > 0)
            {
                motion = afterSpeed * behavior.logicSpeed * Time.deltaTime * spurtDir;
                cacheTransform.position = samplePosition(cacheTransform.position + motion);
                //characterController.Move(motion);
            }
            if (stopFrameOnSpurt)
            {
                behavior.SetCurrentAnimationSpeed(1);
            }
            behavior.Visible = true;
        }
        else
        {
            StopSpurt();
        }
        //lastPos = cacheTransform.position;
    }
    void StopSpurt()
    {
        spurtTime = 0;
        spurtSpeed = 0;
        currentTime = 0;
        behavior.Visible = true;
        behavior.SetCurrentAnimationSpeed(1);
        
        if (behavior.IsSyncPosition)
        {
            SyncPosition();
        }
        //behavior.StopMove();
    }
    public bool IsOnSpurt()
    {
        // 根据时间来判定
        return (beforeTime + spurtTime + afterTime) > currentTime && spurtTime > 0;
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
