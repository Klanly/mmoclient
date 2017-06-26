using UnityEngine;
using System.Collections;


public class MotionTransform : MonoBehaviour {
	
	[UnityEngine.Header("v1.2  Delay & Delete")]
	public float delayTime = 0f;
	public float lifeTime  = 0f;

	[UnityEngine.Header("Transform")]
	public Vector3 moveSpeed = new Vector3(0,0,0);
	public Vector3 rotateSpeed = new Vector3(0,0,0);
	//public Vector3 scaleSpeed = new Vector3(0,0,0);

	[UnityEngine.Header("Sin Transform")]
	public Vector3 sinRange = new Vector3 (0,0,0);
	public float frequency = 5.0f;

	private Transform myTransform;

	// Use this for initialization
	void Start () {
		
		myTransform = this.transform;

		if(delayTime > 0){
			this.gameObject.SetActive (false);
			Invoke ("JasonCreate",delayTime);
		}

		if(lifeTime > 0){
			Invoke ("JasonDelete",lifeTime);
		}

	}

	// Update is called once per frame
	void Update () {
		
		if(moveSpeed != Vector3.zero) myTransform.Translate (moveSpeed*Time.deltaTime,Space.Self);
		if(rotateSpeed != Vector3.zero) myTransform.Rotate (rotateSpeed*Time.deltaTime,Space.Self);
		//if(scaleSpeed != Vector3.zero) myTransform.localScale += scaleSpeed; 


		float xSin = Mathf.Sin(Time.time* frequency) * sinRange.x;
		float ySin = Mathf.Sin(Time.time* frequency) * sinRange.y;
		float zSin = Mathf.Sin(Time.time* frequency) * sinRange.z;

		if(sinRange != Vector3.zero) myTransform.localPosition = new Vector3(xSin, ySin, zSin);

	}

	void JasonCreate (){
		this.gameObject.SetActive (true);
	}
	void JasonDelete (){
		Destroy (this.gameObject);
	}

}