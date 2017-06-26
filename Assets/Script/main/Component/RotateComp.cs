/********************************************************************************
** auth： 转向组件
** date： 2017/5/11
** desc： 
*********************************************************************************/

using UnityEngine;
using System.Collections;
using System;

public class RotateComp : MonoBehaviour
{
    public PuppetBehavior behavior;
    private Transform cacheTransform;

    public bool hasRotation { get; private set; }
    public float rotationY { get; private set; }

    public float rotateSpeed = 10;
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

        if (hasRotation)
        {
            OnRotation();
        }
    }
    void SyncRotation()
    {
        behavior.synComp.SyncSetRotation(cacheTransform.position, rotationY);
    }
    
    public void SetRotation(Quaternion rotation)
    {
        rotationY = rotation.eulerAngles.y;
        if (behavior.IsSyncPosition)
        {
            SyncRotation();
        }
        hasRotation = true;
    }
    public Quaternion GetRotation()
    {
        Quaternion q = Quaternion.Euler(Vector3.up * rotationY);
        return q;
    }
    public void SetLookAt(Vector3 target, bool smooth = false)
    {
        if(smooth)
        {
            Vector3 foward = target - cacheTransform.position;
            float angle = Mathf.Atan2(foward.x, foward.z) * Mathf.Rad2Deg;
            Quaternion euler = Quaternion.Euler(Vector3.up * angle);
            rotationY = euler.eulerAngles.y;
            hasRotation = true;
        }
        else
        {
            //cacheTransform.LookAt(target);
            Vector3 foward = target - cacheTransform.position;
            float angle = Mathf.Atan2(foward.x, foward.z) * Mathf.Rad2Deg;
            Quaternion q = Quaternion.Euler(Vector3.up * angle);
            cacheTransform.rotation = q;
            rotationY = cacheTransform.rotation.eulerAngles.y;
            hasRotation = false;
        }
        if (behavior.IsSyncPosition)
        {
            SyncRotation();
        }
    }
    public void SetForward(Vector3 foward)
    {
        float angle = Mathf.Atan2(foward.x, foward.z) * Mathf.Rad2Deg;
        Quaternion euler = Quaternion.Euler(Vector3.up * angle);
        rotationY = euler.eulerAngles.y;
        if (behavior.IsSyncPosition)
        {
            SyncRotation();
        }
        hasRotation = true;
    }
    public void SetRotateAngle(float y)
    {
        rotationY = y;
        hasRotation = true;
    }

    void OnRotation()
    {
        if (rotationY < 0)
        {
            rotationY += 360;
        }
        float curRotY = cacheTransform.rotation.eulerAngles.y;
        if (curRotY < 0)
        {
            curRotY += 360;
        }

        float angle = rotationY - curRotY;
        if (Mathf.Abs(angle) < 2)
        {
            hasRotation = false;
            return;
        }
        if (angle > 180)
        {
            angle = angle - 360;
        }
        if (angle < -180)
        {
            angle = angle + 360;
        }

        float rotate = angle * rotateSpeed * Time.deltaTime;
        if (angle > 0 && rotate > angle)
        {
            rotate = angle;
        }
        if (angle < 0 && rotate < angle)
        {
            rotate = angle;
        }

        cacheTransform.Rotate(Vector3.up, rotate);
        //Util.Log("Game", string.Format("angle y:{0}, rotate:{1}", angle, rotate));
    }
}
