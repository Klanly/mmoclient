using LuaMessage;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using LuaInterface;

public class EntityBehavior : MonoBehaviour
{
    public string uid;
    public uint sceneid;
    public int entityType;
    public float logicSpeed = 1f;
    public bool isRecyled { get; protected set; }
    public virtual float Speed 
    { 
        get; set;
    }

    public EffectComp effectComp { get; private set; }
    public virtual void OnKnockBarrier(BoxCollider b)
    {
        Util.Log("Game", "OnTrigger uid=" + uid.ToString() + " entityType=" + entityType);
    }
    public void AddEffectGameObject(string resName, string rootName, float recyle, Vector3 pos, Vector3 angle, Vector3 scale, bool detach, bool lossyScale)
    {
        effectComp.AddEffect(resName, rootName, recyle, pos, angle, scale, detach, false, lossyScale);
    }
    public void RemoveEffectGameObject(string effectName)
    {
        effectComp.RemoveEffect(effectName);
    }
    public void RemoveAllEffectGameObject()
    {
        effectComp.RemoveAllEffect();
    }
    public void CastEffect(string effectName, params object[] args)
    {
        effectComp.CastEffect(effectName,args);
    }

    public void RevertEffect()
    {
        effectComp.RevertEffect();
    }

    public virtual void SetLogicSpeed(float speed)  { }

    public virtual void OnNewObject()
    {
        effectComp = gameObject.GetComponent<EffectComp>();
        if (effectComp == null)
        {
            effectComp = gameObject.AddComponent<EffectComp>();
        }
        isRecyled = false;
    }

    public virtual void UpdateLogic(float fUpdateTime) { }

    public virtual void Destroy()
    {
        if (effectComp != null)
        {
            DestroyImmediate(effectComp);
            effectComp = null;
        }
        isRecyled = true;
    }

    public virtual void OnRecycle()
    {
        if (effectComp != null)
        {
            DestroyImmediate(effectComp);
            effectComp = null;
        }
        isRecyled = true;
    }
}
public class EntityBehaviorMgr : Singleton<EntityBehaviorMgr>
{
    private Dictionary<string, EntityBehavior> entityBehaviors = new Dictionary<string, EntityBehavior>();
    private float kUpdateSpeed = 1f;

    public void SetEntityMgrSpeed(float speed)
    {
        kUpdateSpeed = speed;
        string[] keyStr = entityBehaviors.Keys.ToArray();
        if (keyStr.Length < 1) return;
        for (int i = keyStr.Length - 1; i >= 0; i--)
        {
            entityBehaviors[keyStr[i]].SetLogicSpeed(speed);
        }
    }

    public HeroBehavior CreateHero(uint sceneid, string uid, int entityType, GameObject go)
    {
        HeroBehavior hero = go.GetComponent<HeroBehavior>();
        if (hero == null)
        {
            hero = go.AddComponent<HeroBehavior>();
        }
        hero.uid = uid;
        hero.entityType = entityType;
        hero.sceneid = sceneid;

        entityBehaviors.Add(uid, hero);
        hero.OnNewObject();
        
        return hero;
    }

    public DummyBehavior CreateDummy(uint sceneid, string uid, int entityType,GameObject go)
    {
        DummyBehavior dummy = go.GetComponent<DummyBehavior>();
        if (dummy == null)
        {
            dummy = go.AddComponent<DummyBehavior>();
        }
        entityBehaviors.Add(uid, dummy);
        dummy.uid = uid;
        dummy.entityType = entityType;
        dummy.sceneid = sceneid;

        dummy.OnNewObject();
        return dummy;
    }

    public MonsterBehavior CreateMonster(uint sceneid, string uid, int entityType,GameObject go)
    {
        MonsterBehavior monster = go.GetComponent<MonsterBehavior>();
        if (monster == null)
        {
            monster = go.AddComponent<MonsterBehavior>();
        }
        entityBehaviors.Add(uid, monster);
        monster.uid = uid;
        monster.entityType = entityType;
        monster.sceneid = sceneid;

        monster.OnNewObject();
        return monster;
    }

    public PetBehavior CreatePet(uint sceneid, string uid, int entityType, GameObject go)
    {
        PetBehavior pet = go.GetComponent<PetBehavior>();
        if (pet == null)
        {
            pet = go.AddComponent<PetBehavior>();
        }
        entityBehaviors.Add(uid, pet);
        pet.uid = uid;
        pet.entityType = entityType;
        pet.sceneid = sceneid;

        pet.OnNewObject();
        return pet;
    }

    public NPCBehavior CreateNPC(uint sceneid, string uid, int entityType, GameObject go)
    {
        NPCBehavior npc = go.GetComponent<NPCBehavior>();
        if (npc == null)
        {
            npc = go.AddComponent<NPCBehavior>();
        }
        entityBehaviors.Add(uid, npc);
        npc.uid = uid;
        npc.entityType = entityType;
        npc.sceneid = sceneid;

        npc.OnNewObject();
        return npc;
    }


    public SummonBehavior CreateSummon(uint sceneid, string uid, int entityType, GameObject go)
    {
        SummonBehavior t = go.GetComponent<SummonBehavior>();
        if (t == null)
        {
            t = go.AddComponent<SummonBehavior>();
        }
        entityBehaviors.Add(uid, t);
        t.uid = uid;
        t.entityType = entityType;
        t.sceneid = sceneid;

        t.OnNewObject();
        return t;
    }
    public BulletBehavior CreateBullet(uint sceneid, string uid, int entityType, GameObject go)
    {
        BulletBehavior t = go.GetComponent<BulletBehavior>();
        if (t == null)
        {
            t = go.AddComponent<BulletBehavior>();
        }
        entityBehaviors.Add(uid, t);
        t.uid = uid;
        t.entityType = entityType;
        t.sceneid = sceneid;

        t.OnNewObject();
        return t;
    }
    public DropBehavior CreateDrop(uint sceneid, string uid, int entityType, GameObject go)
    {
        DropBehavior t = go.GetComponent<DropBehavior>();
        if (t == null)
        {
            t = go.AddComponent<DropBehavior>();
        }
        entityBehaviors.Add(uid, t);
        t.uid = uid;
        t.entityType = entityType;
        t.sceneid = sceneid;

        t.OnNewObject();
        return t;
    }
    public EmptyGOBehavior CreateEmptyGo(uint sceneid, string uid, int entityType, GameObject go)
    {
        EmptyGOBehavior t = go.GetComponent<EmptyGOBehavior>();
        if (t == null)
        {
            t = go.AddComponent<EmptyGOBehavior>();
        }
        entityBehaviors.Add(uid, t);
        t.uid = uid;
        t.entityType = entityType;
        t.sceneid = sceneid;

        t.OnNewObject();
        return t;
    }

    public BarrierBehavior CreateBarrierBehavior(uint sceneid, string uid, int entityType, Vector3 pos, Vector3 dir, Vector3 scale, GameObject go)
    {
        BarrierBehavior t = go.GetComponent<BarrierBehavior>();
        if (t == null)
        {
            t = go.AddComponent<BarrierBehavior>();
        }
        entityBehaviors.Add(uid, t);
        t.uid = uid;
        t.entityType = entityType;
        t.sceneid = sceneid;

        var tf = go.transform;
        tf.position = pos;
        tf.localScale = scale;
        tf.eulerAngles = dir;

        t.OnNewObject();
        return t;
    }

    public TrickBehavior CreateTrick(uint sceneid, string uid, int entityType, GameObject go)
    {
        TrickBehavior t = go.GetComponent<TrickBehavior>();
        if (t == null)
        {
            t = go.AddComponent<TrickBehavior>();
        }
        entityBehaviors.Add(uid, t);
        t.uid = uid;
        t.entityType = entityType;
        t.sceneid = sceneid;

        t.OnNewObject();
        return t;
    }

    public ConveyTool CreateConveyTool(uint sceneid, string uid, Vector3 rect,GameObject go,LuaTable luaTable)
    {
        ConveyTool t = go.GetComponent<ConveyTool>();
        if (t == null)
        {
            t = go.AddComponent<ConveyTool>();
        }
        entityBehaviors.Add(uid, t);
        t.uid = uid;
        t.sceneid = sceneid;
        t.luaTable = luaTable;

        BoxCollider boxCollider = go.GetComponent<BoxCollider>();
        if (boxCollider == null)
        {
            boxCollider = go.AddComponent<BoxCollider>();
        }
        boxCollider.isTrigger = true;
        boxCollider.size = rect;
        boxCollider.center = new Vector3(0, rect.y / 2, 0);

        return t;
    }

    public EntityBehavior GetEntityBehavior(string uid)
    {
        if (entityBehaviors.ContainsKey(uid))
        {
            return entityBehaviors[uid];
        }
        else
        {
            return null;
        }

    }

    public void UpdateBehavior(float fDeltaTime)
    {
        string[] keyStr = entityBehaviors.Keys.ToArray();
        if (keyStr.Length < 1) return;
        for (int i = keyStr.Length - 1; i >= 0; i--)
        {
            entityBehaviors[keyStr[i]].UpdateLogic(fDeltaTime * kUpdateSpeed);
        }
    }

    public void Destroy(string uid)
    {
        EntityBehavior e = GetEntityBehavior(uid);
        if (e != null)
        {
            GameObject gameObject = e.gameObject;
            if (gameObject != null)
            {
                e.OnRecycle();
                Transform body = gameObject.transform.FindChild("Body");
                if (body != null)
                {
                    body.name = gameObject.name;// 名字改回去
                    ObjectPoolManager.RecycleObject(body.gameObject);   // 只回收Body
                }
                GameObject.DestroyImmediate(gameObject);
            }
            entityBehaviors.Remove(uid);
        }
    }

    public void DestroyAll()
    {
        string[] keyStr = entityBehaviors.Keys.ToArray();
        for (int i = keyStr.Length - 1; i >= 0; i--)
        {
            Destroy(keyStr[i]);
        }
    }
}