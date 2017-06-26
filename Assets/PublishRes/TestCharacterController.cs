using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;

public class TestCharacterController : MonoBehaviour {

    private NavMeshAgent navMeshAgent;
    private bool HasDestination;
    private Animation anim;
    public CameraController cameraController;
    public GameObject Effect
    {
        get
        {
            if (m_effect == null)
            {
                m_effect = ObjectPoolManager.GetSharedResource("yidong/eff_common@yidong", EResType.eResEffect) as GameObject;
            }
            return m_effect;
        }
    }
    GameObject m_effect;

    public void ShowEffect(Vector3 p)
    {
        Effect.SetActive(true);
        Effect.transform.position = new Vector3(p.x, p.y, p.z);
    }

    public void DeactiveEffect()
    {
        Effect.SetActive(false);
    }
	// Use this for initialization
	void Start () {
        navMeshAgent = gameObject.GetComponentInChildren<NavMeshAgent>();
        if (navMeshAgent == null)
        {
            navMeshAgent = gameObject.AddComponent<NavMeshAgent>();
            navMeshAgent.radius = 0F;
            navMeshAgent.speed = 5F;
            navMeshAgent.stoppingDistance = 0.1f;
            navMeshAgent.acceleration = 300.0F;
            navMeshAgent.angularSpeed = 1200.0F;
        }

        anim = transform.GetComponentInChildren<Animation>();
        cameraController.Reset();
	}

    Vector3 GetTerrainPos(Vector3 Dest)
    {
        Ray ray;
        ray = Camera.main.ScreenPointToRay(Dest);
        RaycastHit[] hits = Physics.RaycastAll(ray);
        for (int i = 0; i < hits.Length; i++)
        {
            if (hits[i].collider.gameObject.CompareTag("TerrainGeometry"))
                return hits[i].point;
        }

        return Vector3.zero;
    }

    void Update()
    {
        if(navMeshAgent == null ) return;
        if (HasDestination)
        {
            if (HasArrived())
            {
                Stop();
                anim.CrossFade("NormalStandby");
                HasDestination = false;
                if (Effect.activeSelf) DeactiveEffect();
            }
        }
        if (Input.GetMouseButton(0))
        {
            var TerrainPt = GetTerrainPos(Input.mousePosition);
            if (TerrainPt != Vector3.zero)
            {
                if (Effect.activeSelf) DeactiveEffect();
                navMeshAgent.ResetPath();
                navMeshAgent.SetDestination(TerrainPt);
                HasDestination = true;
                ShowEffect(TerrainPt);
                navMeshAgent.transform.LookAt(TerrainPt);
                anim.CrossFade("run");
            }
        }


    }

    public void Stop()
    {
        if (navMeshAgent == null)
        {
            navMeshAgent = gameObject.GetComponent<NavMeshAgent>();
        }

        if (navMeshAgent.enabled)
        {
            navMeshAgent.Stop();
        }
    }

    public bool HasArrived()
    {

        if (!navMeshAgent.pathPending)
        {
            if (navMeshAgent.remainingDistance <= navMeshAgent.stoppingDistance)
            {
                if (!navMeshAgent.hasPath || navMeshAgent.velocity.sqrMagnitude == 0f)
                {
                    return true;
                }
            }
        }
        return false;
    }

}
