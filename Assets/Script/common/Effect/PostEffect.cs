/********************************************************************************
** auth： yanwei
** date： 2016-12-26
** desc： 后期特效 死亡 动态模糊 Bloom等效果 。
*********************************************************************************/
using UnityEngine;
using System.Collections;

public class PostEffect {

	protected CameraEffect camEffect = null;
	public virtual void OnUpdate() {}
	public virtual void Initialize() 
	{
		camEffect = Camera.main.GetComponent<CameraEffect>();
		if(!camEffect)
		{
			camEffect = Camera.main.gameObject.AddComponent<CameraEffect>();
		}
		camEffect.enabled = false;
	}
	public virtual void OnRecycle() 
	{
		if(camEffect)
		{
			GameObject.DestroyImmediate(camEffect);
			camEffect = null;
		}
	}
	public virtual void CastCameraEffect(params object[] args ) {}
	public virtual void RemoveCameraEffect() {}

}


public class DeathEffect : PostEffect
{
	float kBloomInten = 1f;
	public override void CastCameraEffect(params object[] args) //0: Bloom强度 0~1.8
	{
		base.Initialize();
		camEffect.BloomEnabled = true;
		int count = args == null ? 0 : args.Length;
		if(count> 0)
		{
			kBloomInten = float.Parse(args[0].ToString());
		}
		camEffect.BloomParams.BloomIntensity = kBloomInten;
		camEffect.BloomParams.BloomThreshold = 0.1f;
		camEffect.DeathEffectEnabled =true;
		camEffect.luminAmount = 0.98f;
		camEffect.enabled = true;
	}

	public override void RemoveCameraEffect()
	{
		if(camEffect)
		{
			camEffect.BloomEnabled = false;
			camEffect.DeathEffectEnabled = false;
			camEffect.Init();
		}
	}
}


public class BeHitEffect : PostEffect
{
	bool bEnable = false;
	float speed = 0;
	float kHitInten = 0;
	float maxHitInten = 2.2f;
	public override void CastCameraEffect(params object[] args)
	{
		base.Initialize();
		camEffect.LensDirtEnabled = true;
		camEffect.LensDirtTexture = ResourceManager.LoadTexture("PostEffect/示警_红") as Texture2D;
		int count = args == null ? 0 : args.Length;
		if(count > 0)
		{
			speed = float.Parse(args[0].ToString());
			bEnable = true;
		}
		else
		{
			camEffect.LensDirtIntensity = maxHitInten;
		}

		camEffect.enabled = true;
	}

	public override void RemoveCameraEffect()
	{
		if(camEffect)
		{
			camEffect.LensDirtEnabled = false;
			bEnable = false;
			kHitInten = 0;
			camEffect.Init();
		}
	}

	public override void OnUpdate() 
	{
		if(bEnable)
		{
			kHitInten = kHitInten + Time.deltaTime * speed;
			if(kHitInten < maxHitInten && kHitInten > 0)
			{
				camEffect.LensDirtIntensity = kHitInten;
			}
			else
			{
				speed = -speed;
			}
			camEffect.Init();
		}
	}
}

public class MotionBlurEffect : PostEffect
{
	float kBlurInten = 0;
	public override void CastCameraEffect(params object[] args)
	{
		base.Initialize();
		camEffect.MotionBlurEnabled = true;
		kBlurInten =  float.Parse(args[0].ToString());
		camEffect.Intensity = kBlurInten;
		camEffect.enabled = true;
	}

	public override void RemoveCameraEffect()
	{
		if(camEffect)
		{
			camEffect.MotionBlurEnabled = false;
			kBlurInten = 0;
		}
	}
}


