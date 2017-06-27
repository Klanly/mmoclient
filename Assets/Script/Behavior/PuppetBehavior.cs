/********************************************************************************
** auth： panyinglong
** date： 2016/09/19
** desc： 表现层
*********************************************************************************/

using LuaInterface;
using System;
using UnityEngine;

public class PuppetBehavior : EntityBehavior
{    
    protected Animation anim = null;

    public NavigationComp navigationComp { get; private set; }
    public SpurtComp spurtComp { get; private set; }

    public RotateComp rotateComp { get; private set; }
    public UpdatePosComp updatePosComp { get; private set; }
    //public NavMeshAgent navMeshAgent { get; private set; }
    public AnimationEventSimulator animationEvt { get; private set; }
    public SynComp synComp { get; private set; }
    public AudioSource audioSource { get; private set; }


    public Action<string> OnPlayAnimation;
    
    public string currentAnim;
    public string defaultAnimation = "NormalStandby";
    public string runAnimation = "run";

    private GameObject body;
    private bool isBodyActive = true;
    private bool isPlayEffect = true;
    float timeAtLastFrame = 0F;
    float timeAtCurrentFrame = 0F;
    float deltaTime = 0F;
    bool inReversePlaying = false;
    AnimationState currState = null;
    Transform trans = null;

    private float curAnimPlayTime = 0;
    protected virtual void OnAwake()
    {
        if (!body)
        {
            currentAnim = defaultAnimation;
            trans = transform.FindChild("Body");
            if (trans)
            {
                body = trans.gameObject;
                anim = body.GetComponentInChildren<Animation>();
            }

        }

    }
    
    public void SetPosition(Vector3 pos)
    {
        navigationComp.SetPosition(pos);
    }
    public float GetAnimationLength(string name)
    {
        if (anim.GetClip(name) == null)
        {
            return 0;
        }
        return anim.GetClip(name).length;
    }
    public int GetAnimationWrapMode(string name)
    {
        if (anim.GetClip(name) == null)
        {
            return -1;
        }
        return (int)anim.GetClip(name).wrapMode;
    }
    public bool HasAnimation(string name)
    {
        return anim.GetClip(name) != null;
    }

    public float PlayAnimation(string name)
    {
        if (anim == null) return 0;
        if (anim.GetClip(name) == null)
        {
            return 0;
        }
        if (anim.IsPlaying(name))
        {
            anim.Stop();
        }
        anim.CrossFade(name);
        currentAnim = name;
        anim[currentAnim].speed = logicSpeed;
        if (OnPlayAnimation != null)
        {
            OnPlayAnimation(name);
        }
        curAnimPlayTime = 0;
        return anim.GetClip(name).length/logicSpeed;
    }

    public override void UpdateLogic(float fUpdateTime)
    {
        if (fUpdateTime > 0)
        {
            curAnimPlayTime += fUpdateTime;
            UpdateAnimation();
            timeAtCurrentFrame += fUpdateTime * logicSpeed;
            deltaTime = timeAtCurrentFrame - timeAtLastFrame;
            timeAtLastFrame = timeAtCurrentFrame;
            effectComp.OnUpdate(deltaTime);
            animationEvt.OnUpdateEvent(deltaTime);
        }
        
    }

    // 判断动作是否结束，结束则切到默认动作
    void UpdateAnimation()
    {
        if (body == null)
        {
            OnAwake();
        }
        if (anim == null)
        {
            return;
        }

        if (IsMoving && currentAnim != runAnimation) // 人在跑，但动作没跑
        {
            //Debug.Log(currentAnim + " -> run");
            if(currentAnim == defaultAnimation || curAnimPlayTime > 0.5f) // 移动指令可能先于动作指令执行, 导致移动指令被刷掉, 所以这里设定, 每个指令至少要执行0.1s后才可以被刷掉
            {
                PlayAnimation(runAnimation);
            }       
        }
        else if (currentAnim == runAnimation && !IsMoving) // 动作在跑，但人没有跑
        {
            //Debug.Log("run -> default");
            PlayAnimation(defaultAnimation);
        }
        else if (!anim.IsPlaying(currentAnim) && AutoSwitchNextAnimation) // 动作已经做完了，但没有切成常态动作
        {
            if (defaultAnimation != currentAnim)
            {
                //Debug.Log(currentAnim + " -> default");
                PlayAnimation(defaultAnimation);
            }
        }
    }

    public override void SetLogicSpeed(float lSpeed)
    {
        logicSpeed = lSpeed;
        effectComp.ChangeSpeed(logicSpeed);
        SetCurrentAnimationSpeed(lSpeed);
    }

    //name 传空字符串则表示改变所有的animation速度
    public void SetAnimationSpeed(string name, float speed)
    {
        if (anim == null) return ;
        if (name == "")
        {
            foreach (AnimationState state in anim)
            {
                anim[state.name].speed = speed;
            }
        }
        else
        {
            if (anim.GetClip(name) == null)
            {
                return;
            }
            anim[name].speed = speed;
        }       
    }

    public void SetCurrentAnimationSpeed(float speed)
    {
        SetAnimationSpeed(currentAnim, speed);
    }

    public void StopAnimation(string name)
    {
        if (anim && anim.IsPlaying(name))
        {
            //anim.Stop(name);
            PlayAnimation(defaultAnimation);
        }
    }
    public void SetRotation(Quaternion rotation)
    {
        rotateComp.SetRotation(rotation);
    }
    public Quaternion GetRotation()
    {
        return rotateComp.GetRotation();
    }
    public void SetLookAt(Vector3 target)
    {
        rotateComp.SetLookAt(target, true);
    }

    public void SetModel(GameObject b, float scale)
    {
        gameObject.name = b.name;
        anim = b.GetComponentInChildren<Animation>();

        b.transform.localScale = Vector3.one * scale;
        b.name = "Body";
        b.transform.SetParent(transform);

        if(body != null)
        {
            b.transform.localPosition = body.transform.localPosition;
            b.transform.localRotation = body.transform.localRotation;
            ObjectPoolManager.RecycleObject(body.gameObject);
        }

        if(animationEvt!= null)
        {
            animationEvt.ResetBodyAnim(anim);
        }
        body = b;
    }

    public void SetScale(float scale)
    {
        if(body)
        {
            body.transform.localScale = Vector3.one * scale;
        }
    }
    #region public attribute
    public bool Visible
    {
        set
        {
            //body.SetActive(value);
            if (value)
            {
                body.transform.localScale = Vector3.one;
            }
            else
            {
                body.transform.localScale = new Vector3(0.01f, 0.01f, 0.01f);
            }
        }
        get
        {
            //return body.activeInHierarchy;
            return body.transform.localScale == Vector3.one;
        }
    }
    public bool AutoSwitchNextAnimation { get; set; }

    public override float Speed
    {
        set
        {
            if(value < 0)
            {
                value = 0;
            }
            navigationComp.speed = value;
        }
        get
        {
            return navigationComp.speed;
        }
    }

    public float RotateSpeed
    {
        get
        {
            return rotateComp.rotateSpeed;
        }
        set
        {
            if(value < 0)
            {
                value = 0;
            }
            rotateComp.rotateSpeed = value;
        }
    }

    public float Radius
    {
        set
        {
            if (value < 0.01f)
            {
                value = 0.01f;
            }
            navigationComp.radius = value;
        }
        get
        {
            return navigationComp.radius;
        }
    }

    public float StoppingDistance
    {
        set
        {
            if(value < 0.01f)
            {
                value = 0.01f;
            }
            navigationComp.stoppingDistance = value;
        }
        get
        {
            return navigationComp.stoppingDistance;
        }
    }

    public bool IsDied { get; set; }

    public bool IsBodyActive
    {
        get { return isBodyActive; }
        set
        {
            isBodyActive = value;
            body.SetActive(isBodyActive);
        }
    }

    public bool IsPlayEffect
    {
        get { return isPlayEffect; }
        set { isPlayEffect = value; }
    }

    public bool IsMoving { get { return navigationComp.IsMoving || updatePosComp.IsMoving; } }

    public bool IsSyncPosition {get;set;}
    public bool IsNavMesh { get; set; }
    
    #endregion
    
    public void Moveto(Vector3 pos)
    {
        if(currentAnim != defaultAnimation && currentAnim != runAnimation)
        {
            currentAnim = defaultAnimation;
        }
        updatePosComp.StopMove();
        navigationComp.SetDestination(pos);        
    }
    public void MoveDir(Vector3 dir)
    {
        if (currentAnim != defaultAnimation && currentAnim != runAnimation)
        {
            currentAnim = defaultAnimation;
        }
        updatePosComp.StopMove();
        navigationComp.SetDirection(dir);
    } // 同步服务器的移动
    public void UpdateMoveto(Vector3 pos, float speed, float rotation, float delaytime)
    {
        navigationComp.StopMove();
        updatePosComp.UpdateMoveto(pos, speed, rotation, delaytime);
    }
    public void StopAt(Vector3 pos, float rotation)
    {
        navigationComp.StopMove();
        updatePosComp.StopAt(pos, rotation);
    }

    public void StopMove()
    {
        navigationComp.StopMove();
        updatePosComp.StopMove();
    }

    public override void OnKnockBarrier(BoxCollider b)
    {
        spurtComp.OnKnockBarrier(b);
    }

	public void PlayShake(float range , float duration)
	{
		CameraShake ctl = Camera.main.gameObject.GetComponent<CameraShake>();
		if (ctl == null)
		{
			ctl = Camera.main.gameObject.AddComponent<CameraShake>();
		}
		ctl.Shake(range, duration);
	}

    public void SpurtTo(Vector3 dir, float speed, float beforeTime, float spurtTime, float afterTime, bool visible = true, float beforeSpeed = 0, float afterSpeed = 0, bool stopFrame = true)
    {
        StopMove();
        spurtComp.SetSpurt(dir, speed, beforeTime, spurtTime, afterTime, visible, beforeSpeed, afterSpeed, stopFrame);
    }


    #region animation event 
    protected void PlaySound(AnimationEventSimulator.AnimationEventWrapper e)
    {
        if (currentAnim != e.animationName)
        {
            return;
        }
        AudioClip audioClip = ResourceManager.LoadAudioClip(e.stringParameter);
        if (null == audioClip)
        {
            return;
        }
        audioSource.clip = audioClip;
        audioSource.rolloffMode = AudioRolloffMode.Linear;
        audioSource.spread = 360;
        audioSource.loop = false;
        audioSource.playOnAwake = false;
        audioSource.Play();
    }
    protected void PlayEffect(AnimationEventSimulator.AnimationEventWrapper e)
    {
        if(!IsPlayEffect)
        {
            return;
        }
        if (currentAnim != e.animationName)
        {
            return;
        }

        string resName = e.stringParameter;
        string rootName = e.objectParameter as string;
        Vector3 pos = e.vector3Parameter;
        Vector3 angle = e.vector3Parameter2;
        Vector3 scale = e.vector3Parameter3;
        bool detach = e.boolParameter;
        float recyle = e.floatParameter;
        float delayDestroy = e.floatParameter2;
        float dy = transform.rotation.eulerAngles.y - rotateComp.rotationY;
        angle.y -= dy;
        if (delayDestroy > 0)
        {
            effectComp.AddEffect(resName, rootName, delayDestroy, pos, angle, scale, detach, true, false);
        }
        else
        {
            effectComp.AddEffect(resName, rootName, recyle, pos, angle, scale, detach, false, false);
        }
    }
    
    protected void PlaySpurt(AnimationEventSimulator.AnimationEventWrapper e)
    {
        if (currentAnim != e.animationName)
        {
            return;
        }
        float speed = e.floatParameter;
        float spurtTime = e.floatParameter2;
        float btime = e.floatParameter3;
        float atime = e.floatParameter4;
        float bspeed = e.floatParameter5;
        float aspeed = e.floatParameter6;
        bool visible = e.boolParameter;
        bool stopFrame = e.boolParameter2;
            
        SpurtTo(transform.forward, speed, btime, spurtTime, atime, visible, bspeed, aspeed, stopFrame);
    }

    public void AddSoundEvent(string animName, float triggerTime, string soundRes)
    {
        OnAwake();
        if (anim.GetClip(animName) == null)
        {
            return;
        }
        string playSound = "PlaySound";
        animationEvt.AddSoundEvent(anim[animName], triggerTime, soundRes, playSound);
    }

    public void AddEffectEvent(string animName, float triggerTime, string effectRes, string root, bool isDetach, float durtation, float delayDestory, Vector3 pos, Vector3 rotation, Vector3 scale)
    {
        OnAwake();
        if (anim.GetClip(animName) == null)
        {
            return;
        }
        string playEffect = "PlayEffect";
        animationEvt.AddEffectEvent(anim[animName], triggerTime, effectRes, root, isDetach, durtation, delayDestory, pos, rotation, scale, playEffect);
    }

    /*public void AddShakeEvent(string animName, float triggerTime, float duration, float shakeRange)
    {
        if (anim.GetClip(animName) == null)
        {
            return;
        }
        string playShake = "PlayShake";
		animationEvt.AddShakeEvent(anim[animName], triggerTime, duration, shakeRange, playShake);
    }*/

    public void AddSpurtEvent(string animName, float triggerTime, 
        float spurtSpeed, float beforeTime, float spurtTime, float afterTime, bool visible = true, float beforeSpeed = 0, float afterSpeed = 0, bool stopFrame = true)
    {
        OnAwake();
        if (anim.GetClip(animName) == null)
        {
            return;
        }
        AnimationState state = anim[currentAnim];        
        
        string playSpurt = "PlaySpurt";
        animationEvt.AddSpurtEvent(anim[animName], triggerTime, spurtSpeed, beforeTime, spurtTime, afterTime, playSpurt, visible, beforeSpeed, afterSpeed, stopFrame);
    }


    #endregion

    #region 组件初始化

    public override void OnNewObject()
    {
        //Util.Log("Game", "OnNewObject uid=" + uid + ", entityType=" + entityType.ToString());
        OnAwake();
        base.OnNewObject();

        navigationComp = gameObject.GetComponent<NavigationComp>();
        if (navigationComp == null)
        {
            navigationComp = gameObject.AddComponent<NavigationComp>();
        }
        navigationComp.behavior = this;

        rotateComp = gameObject.GetComponent<RotateComp>();
        if (rotateComp == null)
        {
            rotateComp = gameObject.AddComponent<RotateComp>();
        }
        rotateComp.behavior = this;

        updatePosComp = gameObject.GetComponent<UpdatePosComp>();
        if (updatePosComp == null)
        {
            updatePosComp = gameObject.AddComponent<UpdatePosComp>();
        }
        updatePosComp.behavior = this;

        //navMeshAgent = gameObject.GetComponent<NavMeshAgent>();
        //if (navMeshAgent == null)
        //{
        //    navMeshAgent = gameObject.AddComponent<NavMeshAgent>();
        //    navMeshAgent.radius = 0F;
        //    navMeshAgent.speed = 5F;
        //    navMeshAgent.stoppingDistance = 0.1f;
        //    navMeshAgent.acceleration = 300.0F;
        //    navMeshAgent.angularSpeed = 1200.0F;
        //}        

        animationEvt = gameObject.GetComponent<AnimationEventSimulator>();
        if (animationEvt == null)
        {
            animationEvt = gameObject.AddComponent<AnimationEventSimulator>();
        }
        audioSource = gameObject.GetComponent<AudioSource>();
        if (audioSource == null)
        {
            audioSource = gameObject.AddComponent<AudioSource>();
        }
        synComp = gameObject.GetComponent<SynComp>();
        if (synComp == null)
        {
            synComp = gameObject.AddComponent<SynComp>();
        }

        spurtComp = gameObject.GetComponent<SpurtComp>();
        if(spurtComp == null)
        {
            spurtComp = gameObject.AddComponent<SpurtComp>();
        }
        spurtComp.behavior = this;

        IsSyncPosition = false;
        enabled = true;
        IsDied = false;
        AutoSwitchNextAnimation = true;
    }
    public override void OnRecycle()
    {
        IsSyncPosition = false;
        enabled = false;
        IsDied = false;
        //Util.Log("Game", "OnRecycle uid=" + uid + ", entityType=" + entityType.ToString());

        base.OnRecycle();
        if (navigationComp != null)
        {
            DestroyImmediate(navigationComp);
            navigationComp = null;
        }
        if (rotateComp != null)
        {
            DestroyImmediate(rotateComp);
            rotateComp = null;
        }
        if (updatePosComp != null)
        {
            DestroyImmediate(updatePosComp);
            updatePosComp = null;
        }
        //if (navMeshAgent != null)
        //{
        //    DestroyImmediate(navMeshAgent);
        //    navMeshAgent = null;
        //}
        if (animationEvt != null)
        {
            DestroyImmediate(animationEvt);
            animationEvt = null;
        }
        if (audioSource != null)
        {
            DestroyImmediate(audioSource);
            audioSource = null;
        }
        if (synComp != null)
        {
            DestroyImmediate(synComp);
            synComp = null;
        }
        if(spurtComp != null)
        {
            DestroyImmediate(spurtComp);
            spurtComp = null;
        }
    }
    #endregion

    protected virtual void OnDestroy()
    {
    }  

    public void DestroyComponent(UnityEngine.Object obj)
    {
        if (obj != null)
        {
            DestroyImmediate(obj);
            obj = null;
        }
    }
}
