using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class RotationModel : MonoBehaviour
{

    public Transform target;
    public float speed = 0.1f;

    Transform mTrans;
    float downX = -1;

    void Start()
    {
        mTrans = transform;
    }

    void OnMouseDown()
    {
         downX = Input.mousePosition.x;
    }

    void OnMouseDrag()
    {
        float delta = Input.mousePosition.x - downX;

        if (target != null)
        {
            target.localRotation = Quaternion.Euler(0f, -0.5f * delta * speed, 0f) * target.localRotation;
        }
        else
        {
            mTrans.localRotation = Quaternion.Euler(0f, -0.5f * delta * speed, 0f) * mTrans.localRotation;
        }
    }
}
