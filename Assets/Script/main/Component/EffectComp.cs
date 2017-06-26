/********************************************************************************
** auth： panyinglong
** date： 2016/12/13
** desc： 特效管理组件
*********************************************************************************/

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectComp : MonoBehaviour
{
    public class EffectInfo
    {
        public GameObject effect;
        public float delayDestory;
        public float fupdateTime = 0;
        public bool startCount = true;//开始销毁计时
        public bool bindEffect = false;
    }

    private List<EffectInfo> effects = new List<EffectInfo>();
    public float Speed = 1f;

    void RemoveEffect(EffectInfo effectinfo)
    {
        if (effects.Contains(effectinfo))
        {
            effects.Remove(effectinfo);
            if(effectinfo.effect != null)
            {
                ObjectPoolManager.RecycleObject(effectinfo.effect);
            }            
        }
    }

    public void RemoveEffect(string resName)
    {
        string goName = resName.Replace('/', '_');
        List<EffectInfo> deletes = new List<EffectInfo>();
        for(int i =0; i < effects.Count; i++)
        {
            string name = effects[i].effect.name.Replace("(Clone)", "");
            if (name == goName)
            {
                deletes.Add(effects[i]);
            }
        }
        for(int i = 0; i < deletes.Count; i++)
        {
            RemoveEffect(deletes[i]);
        }
    }

    public void ChangeSpeed(float effectSpeed)
    {
        for (int i = 0; i < effects.Count; i++)
        {
            ParticleSystem[] ps = effects[i].effect.GetComponentsInParent<ParticleSystem>();
            for (int j = 0; j < ps.Length; j++)
                ps[j].playbackSpeed = effectSpeed;
        }
        Speed = effectSpeed;
    }

    public void AddEffect(string resName, string rootName, float recyle, Vector3 pos, Vector3 angle, Vector3 scale, bool detach,bool bindEffect = false, bool lossyScale = false)
    {
        ObjectPoolManager.NewObject(resName, EResType.eResEffect, (obj) =>
        {
            GameObject effect = obj as GameObject;
            if (null == effect || this == null)
            {
                return;
            }

            Transform root = null;
            if (string.IsNullOrEmpty(rootName) || rootName == "root")
            {
                root = transform.Find("Body");
            }
            else
            {
                root = transform.Find("Body/" + rootName);
            }
            if (null == root)
            {
                return;
            }
            // effect.transform.localScale = new Vector3(scale.x / effect.transform.lossyScale.x, scale.y / effect.transform.lossyScale.y, scale.z / effect.transform.lossyScale.z);
            effect.transform.SetParent(root);
            effect.transform.localPosition = pos;
            effect.transform.localEulerAngles = angle;
            if (lossyScale)
            {
                Vector3 transScale = transform.localScale;
                if (transScale.x == 0 || transScale.y == 0 || transScale.z == 0)
                {
                    scale = Vector3.zero;
                }
                else
                {
                    scale = new Vector3(scale.x / transScale.x, scale.y / transScale.y, scale.z / transScale.z);
                }
            }
            effect.transform.localScale = scale;
            if (detach)    //detach
            {
                effect.transform.SetParent(null);
            }
            effect.SetActive(true);
            effect.name = resName.Replace('/', '_'); // 命名
            EffectInfo effectInfo = new EffectInfo();
            effectInfo.delayDestory = recyle;
            effectInfo.effect = effect;
            effectInfo.bindEffect = bindEffect;
            if (bindEffect) effectInfo.startCount = false;
            effects.Add(effectInfo);
            ParticleSystem[] psEffects = effect.GetComponentsInChildren<ParticleSystem>();
            for (int i = 0; i < psEffects.Length; i++)
            {
                psEffects[i].playbackSpeed = Speed;
            }
            Animator[] amitors = effect.GetComponentsInChildren<Animator>();
            for (int i = 0; i < amitors.Length; i++)
            {
                amitors[i].speed = Speed;
            }

        });

    }
    
    public void RemoveAllEffect()
    {
        for(int i = 0; i < effects.Count; i++)
        {
            ObjectPoolManager.RecycleObject(effects[i].effect);
        }
        effects.Clear();
    }

    public void RemoveAllBindEffect()
    {
        for (int i = effects.Count - 1; i >= 0; i--)
        {
            if (effects[i].bindEffect)
            {
                effects[i].startCount = true;
            }
        }
    }

    // 效果组件
	private Effect castEffect;
    public void OnUpdate(float deltaTime)
	{
		if(castEffect)
		{
            castEffect.OnUpdate(deltaTime);
			if(castEffect.RevertComplited)
			{
				DestroyImmediate(castEffect);
				castEffect = null;
			}
		}

        for (int i = 0; i < effects.Count; i++)
        {
            if (effects[i].fupdateTime < effects[i].delayDestory)
            {
                if (effects[i].startCount)
                {
                    effects[i].fupdateTime += deltaTime;
                }
            }
            else if (effects[i].delayDestory > 0)
            {
                RemoveEffect(effects[i]);
            }
         }
	}

	public void CastEffect(string EffectName,params object[] args)
	{
		if(castEffect)
		{
			castEffect.OnRecycle();
			DestroyImmediate(castEffect);
			castEffect = null;
		}
		switch(EffectName)
		{
		   case "FossilisedEffect" :
			    castEffect = gameObject.AddComponent<FossilisedEffect>();
			     break;
		  case "BeHitHighlightEffect" :
			   castEffect = gameObject.AddComponent<BeHitHighlightEffect>();
			    break;
		  case "StealthEffect" :
			   castEffect = gameObject.AddComponent<StealthEffect>();
			   break;
          case "DissolveEffect":
               castEffect = gameObject.AddComponent<DissolveEffect>();
               break;
		   default:
			    break;
		}

		if(castEffect)
		{
			castEffect.SetEffect(args);
		}
	}
    
	public void RevertEffect(bool bDestroy = true)
	{
		if(castEffect)
		{
			castEffect.RevertEffect();
         }

	}

	void OnDestroy()
	{
		if(castEffect)
		{
			castEffect.OnRecycle();
			DestroyImmediate(castEffect);
			castEffect = null;
		}
	}

}
