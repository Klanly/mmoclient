using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Security.Permissions;

public class AnimationEventSimulator : MonoBehaviour
{
    public enum AnimationEventType
    {
        eSound = 0,
        eEffect, 
        eShake,
        eMove,
    }
    public class AnimationEventWrapper
    {
        public AnimationEventType animType;
        public string animationName;
        public AnimationState animState;
        public float triggerTime;
        public string functionName;

        public float floatParameter;
        public float floatParameter2;
        public float floatParameter3;
        public float floatParameter4;
        public float floatParameter5;
        public float floatParameter6;

        public Vector3 vector3Parameter;
        public Vector3 vector3Parameter2;
        public Vector3 vector3Parameter3;

        public int intParameter;
        public string stringParameter;
        public bool boolParameter;
        public bool boolParameter2;
        public object objectParameter;

                
        bool isDone = false; // 已经触发过一次
        public bool IsReady()
        {
            if (isDone)
            {
                return false;
            }
            if (animState.time >= triggerTime * animState.speed)
            {
                isDone = true;
                return true;
            }
            else
            {
                return false;
            }
        }
        public void Stop()
        {
            isDone = false;
        }
    }

    private Dictionary<string, List<AnimationEventWrapper>> animationEvents = new Dictionary<string, List<AnimationEventWrapper>>();

    private PuppetBehavior puppet;
    private string currentAnim;
	delegate void AniEventDelegate(AnimationEventWrapper e);

    void Start()
    {
        puppet = gameObject.GetComponent<PuppetBehavior>();
        if (puppet != null)
        {
            puppet.OnPlayAnimation += OnPlayAnimation;

           // InvokeRepeating("Play", 0, 0.01f);
        }         
    }

    void OnDestroy()
    {
        if (puppet != null)
        {
            puppet.OnPlayAnimation -= OnPlayAnimation;
           // CancelInvoke("Play");
        }
    }

    void OnPlayAnimation(string anim)
    {
        if (!string.IsNullOrEmpty(currentAnim) && animationEvents.ContainsKey(currentAnim))
        {
            foreach (AnimationEventWrapper e in animationEvents[currentAnim])
            {
                e.Stop();
            }
            if (puppet != null)
            {
                puppet.effectComp.RemoveAllBindEffect();
            }
        }
        currentAnim = anim;
    }

    public void OnUpdateEvent(float fdeltaTime)
    {
        if (string.IsNullOrEmpty(currentAnim))
        {
            return;
        }
        if (animationEvents.ContainsKey(currentAnim))
        {
            foreach (AnimationEventWrapper e in animationEvents[currentAnim])
            {
                if (e.IsReady())
                {
					MethodInfo func = typeof(PuppetBehavior).GetMethod(e.functionName, 
						BindingFlags.NonPublic | BindingFlags.Public |BindingFlags.Instance);
					AniEventDelegate kAniEvent = Delegate.CreateDelegate(typeof(AniEventDelegate),puppet,func,false) as AniEventDelegate;
					kAniEvent(e);
				
                }
            }
        }        
    }

    public void AddSoundEvent(AnimationState state, float triggerTime, string soundRes, string funcName)
    {
        AnimationEventWrapper e = new AnimationEventWrapper();
        e.animType = AnimationEventType.eSound;

        e.animState = state;
        e.animationName = state.name;
        e.triggerTime = triggerTime;
        e.stringParameter = soundRes;
        e.functionName = funcName;

        if (!animationEvents.ContainsKey(state.name))
        {
            animationEvents[state.name] = new List<AnimationEventWrapper>();
        }
        animationEvents[state.name].Add(e);
    }

    //isFree表示是否独立于施法单位
    public void AddEffectEvent(AnimationState state, float triggerTime, string effectRes, string root, bool isDetach, float duration, float delayDestroy,
        Vector3 pos, Vector3 rotation, Vector3 scale, string funcName)
    {
        AnimationEventWrapper e = new AnimationEventWrapper();
        e.animType = AnimationEventType.eEffect;

        e.animState = state;
        e.animationName = state.name;
        e.triggerTime = triggerTime;
        e.stringParameter = effectRes;
        e.functionName = funcName;
        e.floatParameter = duration;
        e.floatParameter2 = delayDestroy;
        e.boolParameter = isDetach;
        e.objectParameter = root;

        e.vector3Parameter = pos;
        e.vector3Parameter2 = rotation;
        e.vector3Parameter3 = scale;

        if (!animationEvents.ContainsKey(state.name))
        {
            animationEvents[state.name] = new List<AnimationEventWrapper>();
        }
        animationEvents[state.name].Add(e);
    }

	public void AddShakeEvent(AnimationState state, float triggerTime, float duration, float shakeRange, string funcName)
    {
        AnimationEventWrapper e = new AnimationEventWrapper();
        e.animType = AnimationEventType.eShake;

        e.animState = state;
        e.animationName = state.name;
        e.triggerTime = triggerTime;
        e.functionName = funcName;
		e.floatParameter = duration;
        e.floatParameter = shakeRange;

        if (!animationEvents.ContainsKey(state.name))
        {
            animationEvents[state.name] = new List<AnimationEventWrapper>();
        }
        animationEvents[state.name].Add(e);
    }
    public void AddSpurtEvent(AnimationState state, float triggerTime, 
        float spurtSpeed, float beforeTime, float spurtTime, float afterTime, string funcName, bool visible = true, float beforeSpeed = 0, float afterSpeed = 0, bool stopFrame = true)
    {
        AnimationEventWrapper e = new AnimationEventWrapper();
        e.animType = AnimationEventType.eMove;

        e.animState = state;
        e.animationName = state.name;
        e.triggerTime = triggerTime;
        e.functionName = funcName;
        e.floatParameter = spurtSpeed;
        e.floatParameter2 = spurtTime;
        e.floatParameter3 = beforeTime;
        e.floatParameter4 = afterTime;
        e.floatParameter5 = beforeSpeed;
        e.floatParameter6 = afterSpeed;

        e.boolParameter = visible;
        e.boolParameter2 = stopFrame;

        if (!animationEvents.ContainsKey(state.name))
        {
            animationEvents[state.name] = new List<AnimationEventWrapper>();
        }
        animationEvents[state.name].Add(e);
    }

    public void ResetBodyAnim(Animation anim)
    {
        foreach(KeyValuePair<string, List<AnimationEventWrapper>> kv in animationEvents)
        {
            for(int i = 0; i < kv.Value.Count; i++)            
            {
                AnimationEventWrapper evt = kv.Value[i];
                if(anim.GetClip(evt.animationName))
                {
                    evt.animState = anim[evt.animationName];
                }
            }
        }
    }

    public void Clear()
    {
        animationEvents.Clear();
    }
}
