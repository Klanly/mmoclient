/********************************************************************************
** auth： panyinglong
** date： 2016/09/19
** desc： toy,表现层
*********************************************************************************/

using UnityEngine;

public class ToyBehavior : EntityBehavior
{
    public override float Speed { get; set; }
    public bool hasDestination { get; private set; }

    protected Vector3 destination;
    
    protected Transform cacheTransform = null;
    protected virtual void Awake()
    {
        cacheTransform = transform;
    }

    protected virtual void Update()
    {
        if (hasDestination)
        {
            Vector3 dir = destination - cacheTransform.position;
            Vector3 deltaDir = (Speed / 100 * Time.deltaTime * dir.normalized);
            Vector3 dest = cacheTransform.position + deltaDir;
            Vector3 dirAfter = destination - dest;
            float dot = dir.x * dirAfter.x + dir.z * dirAfter.z;
            
            if (dot < 0 || dir.magnitude < 0.01f) // 多走一步就走过头了
            {
                cacheTransform.position = dest;
                StopMove();
            }
            else        // 还没有到终点
            {
                cacheTransform.position = dest;
            }
        }
    }

    public virtual void SetPosition(Vector3 pos)
    {
        cacheTransform.position = pos;
    }
    public virtual void SetLookAt(Vector3 target)
    {
        cacheTransform.LookAt(target);
    }

    public virtual void SetRotation(Quaternion rotation)
    {
        cacheTransform.rotation = rotation;
    }

    public virtual void SetScale(Vector3 scale)
    {
        cacheTransform.localScale = scale;
    }

    public virtual void Moveto(Vector3 pos)
    {
        cacheTransform.LookAt(pos);
        destination = pos;
        hasDestination = true;
    }
    public virtual void StopMove()
    {
        hasDestination = false;
    }

    //public virtual void SetNavMesh(bool b)
    //{
    //    NavMeshAgent mesh = gameObject.GetComponent<NavMeshAgent>();
    //    if (mesh == null)
    //    {
    //        mesh = gameObject.AddComponent<NavMeshAgent>();
    //    }
    //    mesh.enabled = b;
    //}
    //public override void OnRecycle()
    //{
    //    base.OnRecycle();

    //    NavMeshAgent navMeshAgent = gameObject.GetComponent<NavMeshAgent>();
    //    if (navMeshAgent != null)
    //    {
    //        DestroyImmediate(navMeshAgent);
    //        navMeshAgent = null;
    //    }
    //}
}
