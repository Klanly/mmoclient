using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

[RequireComponent(typeof(Camera))]
public class CullingGroupLoadRes : MonoBehaviour
{
    private List<Target> targets = new List<Target>();
    private CullingGroup group = null;

    private float[] Distances;

    void Awake()
    {
        Distances = new float[4] { 10f, 20f, 45f, 100f }; 
        group = new CullingGroup();
        group.targetCamera = GetComponent<Camera>();
    }

    public void SetCullgroup() 
    {
        group.SetBoundingSpheres(targets.Select(c => c.bound).ToArray());
        group.SetBoundingDistances(Distances);
        group.SetDistanceReferencePoint(transform);
        group.onStateChanged += OnChange;
    }


    void OnDestroy()
    {
        if (group != null)
        {
            group.Dispose();
            group = null;
        }
    }

    public void DestroyCullgroup()
    {
        if (group != null)
        {
            group.onStateChanged -= OnChange;
            targets.Clear();
        }

    }

    void OnChange(CullingGroupEvent ev)
    {
        if (ev.isVisible && ev.currentDistance < 3)
        {
             targets[ev.index].dynamLoadRes.LoadRes();
        }
        else
        {
             targets[ev.index].dynamLoadRes.UnLoadRes();
        }
    }

    public void RegisterObject(Transform transform)
    {
        Target target = new Target(transform.gameObject, transform);
        targets.Add(target);
    }

    public class Target
    {
        private const float size = 18f;

        public Target(GameObject obj, Transform transform)
        {
            bound = new BoundingSphere(transform.position, size);
            dynamLoadRes = obj.GetComponent<DynamLoadRes>();
        }

        public BoundingSphere bound { get; private set; }

        public DynamLoadRes dynamLoadRes { get; private set; }
    }

}
