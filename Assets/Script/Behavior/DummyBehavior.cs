/********************************************************************************
** auth： panyinglong
** date： 2016/09/19
** desc： dummy,表现层
*********************************************************************************/

using UnityEngine;
using System;
using System.Collections.Generic;

public class DummyBehavior : PuppetBehavior
{
    public LayerMask groundLayer = 1 << 14;
    public Action OnFall;
    public Action<Collider> OnColliderHit;
    private BoxCollider boxCollider;

    protected virtual void FixedUpdate()
    {/*
        BoxCollider boxCollider = transform.GetChild(0).GetComponent<BoxCollider>();
        var groundHit = new RaycastHit();
        Ray rayStep = new Ray((transform.position + transform.forward * (boxCollider.size.y / 2)), new Vector3(0, -1, 0));
        if (Physics.Raycast(rayStep, out groundHit, 10, groundLayer))
        {
            float dist = transform.position.y - groundHit.point.y;
            if (dist > 3 && dist < 10)
            {
                //Util.Log("Game", "dist = " + dist);
                //Util.CallMethod("MainLandUICtrl.fightUI", "OnFall");
                if (OnFall != null)
                {
                    //OnFall();     --
                }
            }
        }
        */
    }

    public RaycastHit GetCollider()
    {
        RaycastHit groundHit;
        if (boxCollider == null)
        {
            boxCollider = transform.FindChild("Body").GetComponent<BoxCollider>();
        }

        Vector3 halfHeight = new Vector3(0, 1, 0);
        if (boxCollider)
        {
            halfHeight.y = boxCollider.size.y / 2;
        }
        Ray ray = new Ray((transform.position + halfHeight), transform.forward);
        Physics.Raycast(ray, out groundHit, boxCollider.size.y / 2, 1 << 15);
        return groundHit;
    }

    void OnControllerColliderHit(ControllerColliderHit hit)
    {   /*
        Rigidbody rigidbody = gameObject.GetComponent<Rigidbody>();
        if (rigidbody == null)
        {
            rigidbody = gameObject.AddComponent<Rigidbody>();
        }
        rigidbody.isKinematic = true;
        */

        //Util.CallMethod("MainLandUICtrl.fightUI", "ColliderHit", hit);
    }

    void OnTriggerEnter(Collider col)
    {
        Rigidbody rigidbody = gameObject.GetComponent<Rigidbody>();
        if (rigidbody == null)
        {
            rigidbody = gameObject.AddComponent<Rigidbody>();
            //rigidbody.useGravity = false;
        }
        rigidbody.isKinematic = true;
        //Util.CallMethod("MainLandUICtrl.fightUI", "ColliderHit", col);
        if (OnColliderHit != null)
        {
            OnColliderHit(col);
        }
    }
    /*
    protected override void Update()
    {
        base.Update();
        if (PosteffectsDic.Count > 0)
        {
            foreach (KeyValuePair<string, PostEffect> kv in PosteffectsDic)
            {
                kv.Value.OnUpdate();
            }
        }

    }
    */
    public override void OnNewObject()
    {
        base.OnNewObject();
  
        Rigidbody rigidbody = gameObject.GetComponent<Rigidbody>();
        if (rigidbody == null)
        {
            rigidbody = gameObject.AddComponent<Rigidbody>();
            rigidbody.useGravity = false;
            rigidbody.isKinematic = true;
        }
        //boxCollider = transform.FindChild("Body").GetComponent<BoxCollider>();
    }

    /*
    public void CastCameraEffect(string camEffectName, params object[] args)
    {
        switch (camEffectName)
        {
            case "DeathEffect":
                postEffect = new DeathEffect();
                break;
            case "BeHitEffect":
                postEffect = new BeHitEffect();
                break;
            case "MotionBlurEffect":
                postEffect = new MotionBlurEffect();
                break;
            default:
                break;
        }
        if (postEffect != null)
        {
            if (!PosteffectsDic.ContainsKey(camEffectName))
                PosteffectsDic.Add(camEffectName, postEffect);
            PosteffectsDic[camEffectName].CastCameraEffect(args);
        }

    }

    public void RemoveCameraEffect(string camEffectName)
    {
        if (PosteffectsDic.ContainsKey(camEffectName))
        {
            PosteffectsDic[camEffectName].RemoveCameraEffect();
            PosteffectsDic.Remove(camEffectName);
        }

    }
    
    public override void OnRecycle()
    {
        base.OnRecycle();

        if (PosteffectsDic.Count > 0)
        {
            IList<string> ilistValues = PosteffectsDic.Keys;
            PosteffectsDic[ilistValues[0]].OnRecycle();
            PosteffectsDic.Clear();
        }
    }
    */
}