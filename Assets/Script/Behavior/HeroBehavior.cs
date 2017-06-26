/********************************************************************************
** auth： panyinglong
** date： 2016/09/19
** desc： 英雄,表现层
*********************************************************************************/

using UnityEngine;
using System;
using System.Collections.Generic;

public class HeroBehavior : DummyBehavior
{
	private PostEffect postEffect;
	private SortedList<string,PostEffect> PosteffectsDic = new SortedList<string,PostEffect>();

    public override void UpdateLogic(float fUpdateTime)
	{
        base.UpdateLogic(fUpdateTime);
		if(PosteffectsDic.Count > 0)
		{
			foreach(KeyValuePair<string,PostEffect> kv in PosteffectsDic)
			{
				kv.Value.OnUpdate();
			}
		}
	}
    
	public void CastCameraEffect(string camEffectName, params object[] args)
	{
		switch(camEffectName)
		{
		case "DeathEffect" :
			postEffect = new DeathEffect();
			break;
		case "BeHitEffect" :
			postEffect = new BeHitEffect();
			break;
		case "MotionBlurEffect" :
			postEffect = new MotionBlurEffect();
			break;
		default:
			break;
		}
		if(postEffect!=null)
		{
			if(!PosteffectsDic.ContainsKey(camEffectName))
				PosteffectsDic.Add(camEffectName,postEffect);
			PosteffectsDic[camEffectName].CastCameraEffect(args);
		}

	}

	public void RemoveCameraEffect(string camEffectName)
	{
		if(PosteffectsDic.ContainsKey(camEffectName))
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


}
