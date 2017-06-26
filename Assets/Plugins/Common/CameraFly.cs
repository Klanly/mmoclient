/********************************************************************
	purpose:	摄像机特写镜头
*********************************************************************/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
public class SmoothValuef
{
    public float current_ = 0.0F;
    public List<float> dst_ = new List<float>();
    public int dst_sequence_ = 1;
    public float velocity_ = 0.0F;
    public float time_ = 0.0F;
    //
    public void Update()
    {
        if(Mathf.Abs(current_ - dst_[dst_sequence_]) <= 0.01F)
        {
            ++dst_sequence_;
            if (dst_sequence_ >= dst_.Count)
            {
                dst_sequence_ = 0;
            }
            velocity_ = 0.0F;
        }
        current_ = Mathf.SmoothDamp(current_, dst_[dst_sequence_], ref velocity_, time_);
    }
}
//[ExecuteInEditMode]
public class CameraFly : MonoBehaviour
{
    public float offsetY_ = 3.0F;
    //
    public Transform focus_ = null;
    public SmoothValuef radius_ = new SmoothValuef();
    public SmoothValuef alpha_ = new SmoothValuef();
    public SmoothValuef beta_ = new SmoothValuef();
    public void Awake()
    {
        //
        radius_.time_ = 3.0F;
        radius_.dst_.Add(6.0F);
        radius_.dst_.Add(1.6F);
        radius_.current_ = radius_.dst_[0];
        //
        alpha_.time_ = 6.0F;
        alpha_.dst_.Add(Mathf.PI * 0.0F);
        alpha_.dst_.Add(Mathf.PI * 0.15F);
        alpha_.current_ = alpha_.dst_[0];
        //
        beta_.time_ = 6.0F;
        beta_.dst_.Add(-Mathf.PI * 0.5F);
        beta_.dst_.Add(-Mathf.PI * 0.5F + Mathf.PI * 0.25F);
        beta_.dst_.Add(-Mathf.PI * 0.5F - Mathf.PI * 0.25F);
        beta_.current_ = beta_.dst_[0];
    }
    public void Start()
    {
    }
    private Vector3 GetPosition_()
    {
        Vector3 p = Vector3.zero;
        p.y = radius_.current_ * Mathf.Sin(alpha_.current_);
        float r = radius_.current_ * Mathf.Cos(alpha_.current_);
        p.x = r * Mathf.Cos(beta_.current_);
        p.z = r * Mathf.Sin(beta_.current_);
        return p;
    }
    public void Update()
    {
        if(null == focus_)
        {
            return;
        }
        radius_.Update();
        alpha_.Update();
        beta_.Update();

        
        Vector3 p = focus_.position;
        p.y += offsetY_;
        Camera.main.transform.position = GetPosition_() + p;
        Camera.main.transform.LookAt(p);
    }
}
