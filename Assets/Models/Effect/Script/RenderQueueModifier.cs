using UnityEngine;
using System.Collections;

public class RenderQueueModifier : MonoBehaviour
{
	int _lastQueue = 3000;
    public int offetQueue = 1;

    Renderer[] _renderers;


    void Start()
    {
        _renderers = GetComponentsInChildren<Renderer>();
        if (offetQueue < -50) offetQueue = -50;
        else if (offetQueue > 50) offetQueue = 50;
        Init();
    }

    void Init()
    {
		_lastQueue -= offetQueue;
		foreach (Renderer r in _renderers)
		{
			r.material.renderQueue = _lastQueue;
		}
    }
}