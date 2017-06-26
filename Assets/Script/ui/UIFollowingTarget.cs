using UnityEngine;

public class UIFollowingTarget : MonoBehaviour
{
    [SerializeField]
    Transform _target;
    RectTransform _rt;

    public float xOffset = 0;
    public float yOffset = 0;
    public Vector3 worldOffset = Vector3.zero;
    public Transform target { set { _target = value; } }

    RectTransform rt { get { if (_rt == null) { _rt = GetComponent<RectTransform>(); } return _rt; } }

    void LateUpdate()
    {
        if (_target && rt)
        {
            UIUtil.SetUIPosition(_target.position + worldOffset, rt, xOffset, yOffset);
        }
    }
}
