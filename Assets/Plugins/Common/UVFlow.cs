/********************************************************************
	purpose:	uv动画
*********************************************************************/
using UnityEngine;
using System.Collections;

public class UVFlow : MonoBehaviour 
{
    public float scrollSpeed = 0.005F;
    private Vector2 uv_ = Vector2.zero;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () 
    {
        uv_.x += Time.deltaTime * scrollSpeed;
        GetComponent<Renderer>().material.mainTextureOffset = uv_;
	}
}
