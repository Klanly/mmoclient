/********************************************************************
	purpose:	镜头跟随英雄，球面坐标系
*********************************************************************/
using LuaInterface;
using UnityEngine;
using UnityEngine.EventSystems;

public class CameraController : MonoBehaviour
{
	public float alpha_ = 1.57F;
	public float beta_ = 1.6f;
    float speed_ = 0.15F;

    float distance_ = 11F;
    float offsetDistance = 0;
    float maxOffsetDistance = 4.3f;
    float minOffsetDistance = -8.5f;
    float hideUIDistance = 3;

    float normalRotateX = 45f;
    float offsetRotateX = 0;
    float maxOffestRotateX = 0;
    float minOffestRotateX = -15;

    Vector3 tCameraSpeed_ = Vector3.zero;
    Vector3 cameraRotateSpeed = Vector3.zero;
    float lastDistance = 0f;
    bool smooth = true;
    Camera cacheCamera;
    public LuaTable MainLandUI;
    public LuaTable Joystick;
    public Transform target_ = null;
	float timeDiff = 0;
	float currentTime = 0;
    bool bReset = false;
    void Awake()
    {
        cacheCamera = GetComponent<Camera>();
    }

    public void Reset()
    {
        if (null == target_)
        {
            return;
        }
        offsetDistance = 0;
        offsetRotateX = 0;
		initial = false;
		initialTime = false;
        bReset = true;
        cacheCamera.transform.position = GetDestination(target_);
        smooth = true;
    }

    public void ResetPosition()
    {
        if (null == target_)
        {
            return;
        }
        offsetDistance = 0;
        offsetRotateX = 0;
        //cacheCamera.transform.position = GetDestination(target_);
        //cacheCamera.transform.eulerAngles = new Vector3(normalRotateX + offsetRotateX, -90, 0);
    }

    public Vector3 GetFarestPoint()
    {
        offsetDistance = 5;
        //smooth = false;
        return Vector3.zero;
    }

    Vector3 GetDestination(Transform transform)
    {
        Vector3 p = transform.position;
        if (target_)
        {
			p.y += (distance_ + offsetDistance) * Mathf.Sin(beta_);
			p.z -= (distance_ + offsetDistance) * Mathf.Cos(alpha_) - lowFlyMoveZ;
			p.x += (distance_ + offsetDistance) * Mathf.Sin(alpha_);
        }
        return p;
    }

    bool initial = false;
	bool initialTime = false;
    void LateUpdate()
    {
        if (null == target_ || !bReset)
        {
            bReset = false;
            return;
        }

        if (maxOffsetDistance == 0) maxOffsetDistance = 1;
        if (minOffsetDistance == 0) minOffsetDistance = -1;
		float deltaDistance = 0;

		if (lowFlyState == 1||lowFlyState == 2)           //镜头初变时间内
		{
			if (isLowFlyChangeDir)
			{
				lowFlyDelateDistance = -lowFlyA * Mathf.Sin(lowFlyAngle.y * Mathf.Deg2Rad);  //镜头上下拉伸值
				lowFlyDelateDistance = Mathf.Clamp(lowFlyDelateDistance, -20, 10);
				lowFlyMoveZ = -lowFlyB * Mathf.Cos(lowFlyAngle.y * Mathf.Deg2Rad);  //镜头左右拉伸值
				speed_ = lowFlyM;
			}
			timeDiff = Time.time - lowFlyTime;
			if (lowFlyState==1&&timeDiff > lowFlyM)
			{
				speed_ = lowFlyN;
				lowFlyMoveZ = 0;  //镜头左右拉伸回归值
				lowFlyTime = Time.time;
				lowFlyDelateDistance = 0;
				offsetDistance = 0;
				lowFlyState = 2;
				timeDiff = 0;
			}
			if (lowFlyState==2&&timeDiff > lowFlyN)//回归时间 延时半秒
			{
				lowFlyState = 0;
			}
		}
        if (Application.isMobilePlatform)
        {
            if (Input.touchCount == 2 && (Input.GetTouch(0).phase == TouchPhase.Moved || Input.GetTouch(1).phase == TouchPhase.Moved)
                && !EventSystem.current.IsPointerOverGameObject(Input.GetTouch(0).fingerId)
                && !EventSystem.current.IsPointerOverGameObject(Input.GetTouch(1).fingerId) && !(bool)Joystick["drag"])
            {
                var touch1 = Input.GetTouch(0);
                var touch2 = Input.GetTouch(1);
                float curDistance = Vector2.Distance(touch1.position, touch2.position);
                if(lastDistance != 0)
                    deltaDistance = (lastDistance - curDistance) * 0.01f;
                lastDistance = curDistance;
            }
            else
            {
                lastDistance = 0;
            }
        }
        else if (EventSystem.current && !EventSystem.current.IsPointerOverGameObject())
        {
            Vector3 ViewPortPoint = Camera.main.ScreenToViewportPoint(Input.mousePosition);
            if (ViewPortPoint.x < 1 && ViewPortPoint.x > 0 && ViewPortPoint.y > 0 && ViewPortPoint.y < 1)
                deltaDistance = Input.GetAxis("Mouse ScrollWheel") * 4;
        }
        offsetDistance += deltaDistance;
        offsetDistance = Mathf.Clamp(offsetDistance, minOffsetDistance, maxOffsetDistance);
		offsetDistance += lowFlyDelateDistance;

        if (deltaDistance != 0 && 
            (Mathf.Abs((offsetDistance - maxOffsetDistance) * (offsetDistance - deltaDistance - maxOffsetDistance)) <= 0.01 
            || Mathf.Abs((offsetDistance - minOffsetDistance) * (offsetDistance - deltaDistance - minOffsetDistance)) <= 0.01))
            if (MainLandUI != null) Util.CallMethod(MainLandUI, "SwitchUIState", offsetDistance != maxOffsetDistance && offsetDistance != minOffsetDistance );

        if (offsetDistance < minOffsetDistance) offsetDistance = minOffsetDistance;
        offsetRotateX += offsetDistance > 0 ? deltaDistance * maxOffestRotateX / maxOffsetDistance : deltaDistance * minOffestRotateX / minOffsetDistance;
        offsetRotateX = Mathf.Clamp(offsetRotateX, minOffestRotateX, maxOffestRotateX);
        Vector3 current = cacheCamera.transform.position;
 
        if (initial == false) //初始相机有个俯冲效果
        {
			if(initialTime == false)
			{
				offsetDistance += 16;
				current = GetDestination(target_);
				cacheCamera.transform.eulerAngles = new Vector3(normalRotateX + offsetRotateX, -90, 0);
				cacheCamera.transform.position = current;
				offsetDistance -= 16;
				cacheCamera.fieldOfView = 45;
				initialTime = true;
				currentTime = Time.time;
				speed_ = 0.3f;
			}
			else
			{
				timeDiff = Time.time - currentTime;
				if(timeDiff > (speed_+0.1f))
				{
					initial = true;
					speed_ = 0.15f;
				}
			}
        }

		Vector3 dst = GetDestination(target_);
		Vector3 currentRotate = cacheCamera.transform.eulerAngles;
		Vector3 dstRotate = new Vector3(normalRotateX + offsetRotateX, currentRotate.y, 0);
		cacheCamera.transform.position = smooth?Vector3.SmoothDamp(current, dst, ref tCameraSpeed_, speed_): dst;
		cacheCamera.transform.eulerAngles = Vector3.SmoothDamp(currentRotate, dstRotate, ref cameraRotateSpeed, speed_);
		offsetDistance -= lowFlyDelateDistance;//还原距离
		isLowFlyChangeDir = false;
		lowFlyMoveZ = 0;
		if(cacheCamera.farClipPlane > 150)
		    cacheCamera.farClipPlane = 150f + 5f*offsetDistance;
		else
		    cacheCamera.farClipPlane = 150f + 12f*offsetDistance;
        if (cacheCamera.farClipPlane < 24f)
            cacheCamera.farClipPlane = 24f;
    }

	public void SetSmoothSpeed(float speed)
	{
		speed_ = speed;
	}
	/// <summary>
	/// The low fly a.
	/// </summary>
    float lowFlyA = 1;
    float lowFlyB = 1;
    float lowFlyM = 0.4f;   //镜头初变时间
	float lowFlyN = 0.4f;   //镜头回归时间
    float lowFlyMoveZ = 0;   //左右移动
    float lowFlyTime = 0;
    float lowFlyDelateDistance = 0;
    int lowFlyState = 0; //状态为1表示镜头初变时间内，状态为2表示镜头回归时间内，状态为0表示正常状态

    Vector3 lowFlyAngle = Vector3.zero;
    bool isLowFlyChangeDir = false;

    public void SetLowFlyPara(float a, float b, float M, float N, Vector3 angle)
    {
        lowFlyA = a;
        lowFlyB = b;
		lowFlyM = M;
		lowFlyN = N;
        lowFlyAngle = angle;
        isLowFlyChangeDir = true;

        lowFlyTime = Time.time;
        lowFlyState = 1;
    }
}
