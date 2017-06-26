using UnityEngine;
using System.Collections;

public class MiniMapCamera : MonoBehaviour {

    public Camera camera_;
    public GameObject hero_;
    public float height_ = 70.0f;
	
	// Update is called once per frame
	void FixedUpdate()
    {
        if (hero_ == null)
        {
            return;
        }
        gameObject.transform.position = new Vector3(hero_.transform.position.x,hero_.transform.position.y+height_,hero_.transform.position.z);
        //gameObject.transform.LookAt(hero_.transform.position);
		// 如果必要，再加入height，待定
        //gameObject.transform.position = Camera.main.transform.position;
        gameObject.transform.rotation = Quaternion.Euler(90, Camera.main.transform.rotation.eulerAngles.y, 0);
	}
}
