/********************************************************************************
** auth： 张增
** date： 2016/09/12
** desc： 屏障
*********************************************************************************/
using UnityEngine;

public class BarrierBehavior : EntityBehavior
{
    void OnTriggerEnter(Collider other)
    {
        Transform colliderTransform = other.transform;
        EntityBehavior entityBehavior = colliderTransform.GetComponent<EntityBehavior>();
        if (entityBehavior)
        {
            BoxCollider box = gameObject.GetComponent<BoxCollider>();
            entityBehavior.OnKnockBarrier(box);
        }
    }

    //void OnTriggerStay(Collider other)
    //{
    //    NavigationComp navigationComp;
    //    Transform colliderTransform = other.transform;
    //    NavMeshAgent navMeshAgent = colliderTransform.GetComponent<NavMeshAgent>();
    //    if (navMeshAgent)
    //    {
    //        //Vector3 destination = navMeshAgent.destination;
    //        //Vector3 pos = navMeshAgent.transform.position;
    //        navigationComp = colliderTransform.GetComponent<NavigationComp>();

    //        Vector3 moveDir = navigationComp.MoveDir;
    //        if (moveDir.x == 0 && moveDir.y == 0 && moveDir.z == 0)
    //            return;

    //        //if (navigationComp.MoveDir ！= Vector3.zero)
    //        {
    //            Vector3 forward = transform.forward;

    //            float dot = Vector3.Dot(moveDir, forward);
    //            //向量a,b的夹角,得到的值为弧度，我们将其转换为角度 
    //            float angle = Mathf.Acos(Vector3.Dot(moveDir.normalized, forward.normalized)) * Mathf.Rad2Deg;
    //            if ((angle) < 90)
    //            {

    //                if (navigationComp)
    //                {
    //                    navigationComp.Stop();
    //                }
    //            }
    //        }
    //    }
    //}

    public override void OnNewObject()
    {
        base.OnNewObject();
    }
}
