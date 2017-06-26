using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ShadowProjector : MonoBehaviour 
{
    private Projector _projector;
    //
    private Camera _lightCamera = null;
    private RenderTexture _shadowTex;
    //
    private Camera _mainCamera;
    private List<Renderer> _shadowCasterList = new List<Renderer>();
    private BoxCollider _boundsCollider;
    public LayerMask CastShadowLayers;
    public int SizeTex = 512;
    public float boundsOffset = 1;//边界偏移，
    public Shader shadowReplaceShader;

	void Start () 
    {
        _projector = GetComponent<Projector>();
        _mainCamera = Camera.main;
        //
        if(_lightCamera == null)
        {
            _lightCamera = gameObject.AddComponent<Camera>();
            _lightCamera.orthographic = true;
            _lightCamera.cullingMask = CastShadowLayers;
            _lightCamera.clearFlags = CameraClearFlags.SolidColor;
            _lightCamera.backgroundColor = new Color(0,0,0,0);
            _shadowTex = new RenderTexture(SizeTex, SizeTex, 0, RenderTextureFormat.Default);
            _shadowTex.filterMode = FilterMode.Bilinear;
            _lightCamera.targetTexture = _shadowTex;
            _lightCamera.SetReplacementShader(shadowReplaceShader, "RenderType");
            _projector.material.SetTexture("_ShadowTex", _shadowTex);
           // _projector.ignoreLayers = LayerMask.GetMask("ShadowCaster");
        }
     
	}

    void LateUpdate()
    {
        //求阴影产生物体的包围盒
        /*Bounds b = new Bounds();
        for (int i = 0; i < _shadowCasterList.Count; i++)
        {
            if(_shadowCasterList[i] != null)
            {
                b.Encapsulate(_shadowCasterList[i].bounds);
            }
        }
        b.extents += Vector3.one * boundsOffset;
#if UNITY_EDITOR
        _boundsCollider.center = b.center;
        _boundsCollider.size = b.size;
#endif
        //根据mainCamera来更新lightCamera和projector的位置，和设置参数
        ShadowUtils.SetLightCamera(b, _lightCamera);*/

        if (_mainCamera == null)
        {
            _mainCamera = Camera.main;
        }
        if (_mainCamera == null) return;
        ShadowUtils.SetLightCamera(_mainCamera, _lightCamera);
        _projector.aspectRatio = _lightCamera.aspect;
        _projector.orthographicSize = _lightCamera.orthographicSize;
        _projector.nearClipPlane = _lightCamera.nearClipPlane;
        _projector.farClipPlane = _lightCamera.farClipPlane;
        


    }
}
