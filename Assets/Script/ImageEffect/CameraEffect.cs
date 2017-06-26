#define CAMERA_EFFECT
#if CAMERA_EFFECT
#define BLOOMPRO_EFFECT
#define DOFPRO_EFFECT
#endif
using UnityEngine;
using System.Collections.Generic;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
[AddComponentMenu( "Image Effects/CameraEffect™" )]
public class CameraEffect : MonoBehaviour	
{
    public EffectsQuality Quality = EffectsQuality.Fast;

	private static Material _mat;

    public static Material Mat
    {
        get
        {
            if (null == _mat)
				_mat = new Material(ResourceManager.GetMaterial("CamEffect/CameraEffectMat"))  {
                    hideFlags = HideFlags.HideAndDontSave
                };

            return _mat;
        }
    }

    private static Material _tapMat;

    private static Material TapMat
    {
        get
        {
            if ( null == _tapMat )
				_tapMat = new Material(ResourceManager.GetMaterial("CamEffect/CameraEffectMat")) 
                {
                    hideFlags = HideFlags.HideAndDontSave
                };

            return _tapMat;
        }
    }
    
    private Camera _effectCamera;
    
    private Camera EffectCamera {
    	get {
    		if (null == _effectCamera)
    			_effectCamera = GetComponent<Camera>();
    			
    		return _effectCamera;
    	}
    }

    //Bloom
#if BLOOMPRO_EFFECT
    public bool BloomEnabled = false;
    public BloomHelperParams BloomParams = new BloomHelperParams();
    public bool VisualizeBloom = false;
#endif

	public Texture2D LensDirtTexture = null;

	[Range(0f, 2.5f)]
	public float LensDirtIntensity = 2f;
	
    public bool LensDirtEnabled = false;

    //Depth of Field
#if DOFPRO_EFFECT
    public bool DOFEnabled = false;
    public bool BlurCOCTexture = true;
    public DOFHelperParams DOFParams = new DOFHelperParams();

    public bool VisualizeCOC = false;
#endif

    public bool HalfResolution = false;

	public bool DeathEffectEnabled = false;
	[Range(0.0f, 1f)]
	public float luminAmount = 0.9f;
    // 运动模糊
    public bool MotionBlurEnabled = false;
    [Range(0f, 5f)]
    public float Intensity = 2.2f;

	[Range(0f, 3f)]
	public float SampleDist = 0.4f;

    public void Start() 
	{
#if !UNITY_5
		if ( !Application.HasProLicense() ) {
			Debug.LogError("You don't have a Unity Pro license. Image effects are not supported.");
			enabled = false;
			return;
		}
#endif
	
		if (!SystemInfo.supportsImageEffects || !SystemInfo.supportsRenderTextures)
		{
			Debug.LogError("Image effects are not supported on this platform.");
			enabled = false;
			return;
		}

	}

	public void Init(bool searchForNonDepthmapAlphaObjects = false) {
		if (HalfResolution)
			Screen.SetResolution( Screen.currentResolution.width / 2, Screen.currentResolution.height / 2, Screen.fullScreen, Screen.currentResolution.refreshRate);
	
        Mat.SetFloat( "_DirtIntensity", Mathf.Exp( LensDirtIntensity ) - 1f );

		if (!LensDirtEnabled||null == LensDirtTexture || LensDirtIntensity <= 0f) {
            Mat.DisableKeyword( "LENS_DIRT_ON" );
            Mat.EnableKeyword( "LENS_DIRT_OFF" );
        } else {
            Mat.SetTexture( "_LensDirtTex", LensDirtTexture );
            Mat.EnableKeyword( "LENS_DIRT_ON" );
            Mat.DisableKeyword( "LENS_DIRT_OFF" );
        }

		if (EffectCamera.hdr) {
            Shader.EnableKeyword( "FXPRO_HDR_ON" );
            Shader.DisableKeyword( "FXPRO_HDR_OFF" );
        } else {
            Shader.EnableKeyword( "FXPRO_HDR_OFF" );
            Shader.DisableKeyword( "FXPRO_HDR_ON" );
        }


		//Enable depth texture
		if (DOFEnabled) {
			if ( EffectCamera.depthTextureMode == DepthTextureMode.None )
				EffectCamera.depthTextureMode = DepthTextureMode.Depth;
		}

        //
        //Depth of Field
#if DOFPRO_EFFECT
        if (DOFEnabled) {

            if (null == DOFParams.EffectCamera) {
					DOFParams.EffectCamera = EffectCamera;
            }

            DOFParams.DepthCompression = Mathf.Clamp( DOFParams.DepthCompression, 2f, 8f );

            DOFHelper.Instance().SetParams( DOFParams );
			DOFHelper.Instance().Init( searchForNonDepthmapAlphaObjects );
			
			Mat.DisableKeyword( "DOF_DISABLED" );
            Mat.EnableKeyword( "DOF_ENABLED" );

            //Less blur when using fastest quality
            if (!DOFParams.DoubleIntensityBlur)
                DOFHelper.Instance().SetBlurRadius( (Quality == EffectsQuality.Fastest || Quality == EffectsQuality.Fast) ? 3 : 5 );
            else
                DOFHelper.Instance().SetBlurRadius( (Quality == EffectsQuality.Fastest || Quality == EffectsQuality.Fast) ? 5 : 10 );
        } else {
            Mat.EnableKeyword( "DOF_DISABLED" );
            Mat.DisableKeyword( "DOF_ENABLED" );
        }
#endif

        //
        //Bloom
#if BLOOMPRO_EFFECT
        if (BloomEnabled) {
            BloomParams.Quality = Quality;
            BloomHelper.Instance().SetParams(BloomParams);
            BloomHelper.Instance().Init();

            Mat.DisableKeyword("BLOOM_DISABLED");
            Mat.EnableKeyword("BLOOM_ENABLED");
        } else {
            Mat.EnableKeyword( "BLOOM_DISABLED" );
            Mat.DisableKeyword( "BLOOM_ENABLED" );
        }
#endif
		if (DeathEffectEnabled) {

			Mat.DisableKeyword("DEATH_GRAY_DISABLED");
			Mat.EnableKeyword("DEATH_GRAY");
		} else {
			Mat.EnableKeyword( "DEATH_GRAY_DISABLED" );
			Mat.DisableKeyword( "DEATH_GRAY" );
		}

	}
	
	public void OnEnable() {
		Init( true );
	}

    public void OnDisable()
	{
		if(null != Mat)
			DestroyImmediate(Mat);
		
		RenderTextureManager.Instance.Dispose();
		
#if DOFPRO_EFFECT
        DOFHelper.Instance().Dispose();
#endif
        
#if BLOOMPRO_EFFECT
		BloomHelper.Instance().Dispose();
#endif
	}

    //
    //Settings:
    //
    //High:     10 blur, 5 samples
    //Normal:   5 blur, 5 samples
    //Fast:     5 blur, 3 samples
    //Fastest:  5 blur, 3 samples, 2 pre-samples



    public void OnValidate()
	{
		Init( false );
	}
	
	public static RenderTexture DownsampleTex( RenderTexture input, float downsampleBy ) {
		RenderTexture tempRenderTex =  RenderTextureManager.Instance.RequestRenderTexture( Mathf.RoundToInt( (float)input.width / downsampleBy ), Mathf.RoundToInt( (float)input.height / downsampleBy ), input.depth, input.format);
		tempRenderTex.filterMode = FilterMode.Bilinear;
		
		//Downsample pass
//		Graphics.Blit(input, tempRenderTex, _mat, 1);

        const float off = 1f;
        Graphics.BlitMultiTap( input, tempRenderTex, TapMat,
            new Vector2( -off, -off ),
            new Vector2( -off, off ),
            new Vector2( off, off ),
            new Vector2( off, -off )
        );
		
		return tempRenderTex;
	}


    void RenderEffects(RenderTexture source, RenderTexture destination)
    {
        source.filterMode = FilterMode.Bilinear;

		RenderTexture curRenderTex = source;
        RenderTexture srcProcessed = source;

        curRenderTex = DownsampleTex(srcProcessed, 2f);

        if (Quality == EffectsQuality.Fastest)
            RenderTextureManager.Instance.SafeAssign( ref curRenderTex, DownsampleTex( curRenderTex, 2f ) );

#if DOFPRO_EFFECT
        RenderTexture cocRenderTex = null, dofRenderTex = null;
        if (DOFEnabled) {
            if (null == DOFParams.EffectCamera) {
                Debug.LogError( "null == DOFParams.camera" );
                return;
            }

            cocRenderTex = RenderTextureManager.Instance.RequestRenderTexture( curRenderTex.width, curRenderTex.height, curRenderTex.depth, curRenderTex.format );

            DOFHelper.Instance().RenderCOCTexture(curRenderTex, cocRenderTex, BlurCOCTexture ? 1.5f : 0f);

            if (VisualizeCOC) {
                Graphics.Blit( cocRenderTex, destination, DOFHelper.Mat, 3 );
                RenderTextureManager.Instance.ReleaseRenderTexture( cocRenderTex );
                RenderTextureManager.Instance.ReleaseRenderTexture( curRenderTex );
                return;
            }

            dofRenderTex = RenderTextureManager.Instance.RequestRenderTexture(curRenderTex.width, curRenderTex.height, curRenderTex.depth, curRenderTex.format);

            DOFHelper.Instance().RenderDOFBlur(curRenderTex, dofRenderTex, cocRenderTex);

            Mat.SetTexture( "_DOFTex", dofRenderTex );
            Mat.SetTexture( "_COCTex", cocRenderTex );

            //Make bloom DOF-based?
            //RenderTextureManager.Instance.SafeAssign(ref curRenderTex, dofRenderTex);

            //Graphics.Blit( dofRenderTex, destination );
        }
#endif

        //Render bloom
#if BLOOMPRO_EFFECT
        if (BloomEnabled) {
            RenderTexture bloomTexture = RenderTextureManager.Instance.RequestRenderTexture(curRenderTex.width, curRenderTex.height, curRenderTex.depth, curRenderTex.format);
            BloomHelper.Instance().RenderBloomTexture(curRenderTex, bloomTexture);

            Mat.SetTexture("_BloomTex", bloomTexture);

            if ( VisualizeBloom )
            {
                Graphics.Blit( bloomTexture, destination );
                return;
            }
        }
#endif
		if(DeathEffectEnabled)
		{
			Mat.SetFloat("_luminAmount", luminAmount);
		}
        if(MotionBlurEnabled)
        {
			Mat.SetFloat("Strength", Intensity);
			Mat.SetFloat("SampleDist", SampleDist);
            Graphics.Blit(srcProcessed, destination, Mat,2);
        }
		else
            Graphics.Blit( srcProcessed, destination, Mat, 0 );

		RenderTextureManager.Instance.ReleaseRenderTexture( srcProcessed );

#if DOFPRO_EFFECT
        RenderTextureManager.Instance.ReleaseRenderTexture( cocRenderTex );
        RenderTextureManager.Instance.ReleaseRenderTexture( dofRenderTex );
#endif

        RenderTextureManager.Instance.ReleaseRenderTexture( curRenderTex );

    }

	//[ImageEffectOpaque]
    [ImageEffectTransformsToLDR]
    public void OnRenderImage( RenderTexture source, RenderTexture destination )
	{
	    RenderEffects(source, destination);
		RenderTextureManager.Instance.ReleaseAllRenderTextures();
	}
}