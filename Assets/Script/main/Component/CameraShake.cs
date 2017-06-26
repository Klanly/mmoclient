/********************************************************************************
** auth： panyinglong
** date： 2016/09/28
** desc： 相机抖动
*********************************************************************************/
using UnityEngine;
using System.Collections;
public class CameraShake : MonoBehaviour
{
    public float shakeRange = 0.5f;
	public float current_ = 0.0f;
	public float speed_ = 0.0f;
	public Vector2 rand_ = Vector2.zero;
	private float alpha_ = 0.0f;
	private float beta_ = 0.0f;
	public float shaketime = 0.3f;

	public void OnEnable()
	{
		alpha_ = Camera.main.GetComponent<CameraController>().alpha_;
		beta_ = Camera.main.GetComponent<CameraController>().beta_;
		current_ = shakeRange;
		speed_ = 0.0f;
		StartCoroutine(WaitAndEnd(shaketime));
	}
	public void Shake(float range, float duration)
    {
        shakeRange = range;
		shaketime = duration;
        enabled = true;
    }
    
	IEnumerator WaitAndEnd(float waitTime)
	{
		yield return new WaitForSeconds(waitTime);
		enabled = false;
	}
	void OnDespawned()
	{
		OnDisable();
	}
	public void OnDisable()
	{
		if (null != Camera.main && null != Camera.main.GetComponent<CameraController>())
		{
			Camera.main.GetComponent<CameraController>().alpha_ = alpha_;
			Camera.main.GetComponent<CameraController>().beta_ = beta_;
		}

		current_ = shakeRange;
		speed_ = 0.0f;
	}

    void Update()
    {

		//camTransform.localPosition = originalPos + Random.insideUnitCircle * shakeRange;
		current_ = Mathf.SmoothDamp(current_, 0.0f, ref speed_, shaketime);
		rand_ = Random.insideUnitCircle * current_;
		Camera.main.GetComponent<CameraController>().alpha_ = alpha_ + rand_.x;
		Camera.main.GetComponent<CameraController>().beta_ = beta_ + rand_.y;

    }
}