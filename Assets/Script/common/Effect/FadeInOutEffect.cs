using System.Diagnostics;
using System.Security;
using UnityEngine;
using System.Collections;
using Debug = UnityEngine.Debug;

public class FadeInOutEffect : MonoBehaviour
{
	public string ShaderColorName = "_Color";
	public float StartDelay = 0;
	public float FadeInSpeed = 0;
	public float FadeOutDelay = 0;
	public float FadeOutSpeed = 0;
	public bool UseSharedMaterial;
	public bool FadeOutAfterCollision;
	public bool UseHideStatus;

	private Renderer[] renders;
	private Material[] mats;
	private Color oldColor, currentColor;
	private float oldAlpha, alpha;
	private bool canStart, canStartFadeOut, fadeInComplited, fadeOutComplited;
	private bool isStartDelay, isIn, isOut;
	private bool isInitialized;
	private int matLength = 0;
	private int oldLayer = 0;

	#region Non-public methods


	private void Start()
	{
		InitMaterial();
	}

	private void InitMaterial()
	{
		if (isInitialized) return;
		renders = transform.GetComponentsInChildren<Renderer>();
		if(renders==null) return;
		matLength = renders.Length;
		if(matLength < 1) return;
		mats = new Material[renders.Length];
		for(int i = 0;i< matLength;i++)
			mats[i] = renders[i].material;
		oldLayer = gameObject.layer;
		if(!mats[0].HasProperty(ShaderColorName)) return;
		oldColor = mats[0].GetColor(ShaderColorName);
		isStartDelay = StartDelay > 0.001f;
		isIn = FadeInSpeed > 0.001f;
		isOut = FadeOutSpeed > 0.001f;
		InitDefaultVariables();
		foreach(Transform tran in GetComponentsInChildren<Transform>())
			tran.gameObject.layer = 1;
		isInitialized = true;

	}

	private void InitDefaultVariables()
	{
		fadeInComplited = false;
		fadeOutComplited = false;
		canStartFadeOut = false;
		oldAlpha = 0;
		alpha = 0;
		canStart = false;

		currentColor = oldColor;
		if (isIn) currentColor.a = 0;
		for(int i = 0;i< matLength;i++)
			mats[i].SetColor(ShaderColorName, currentColor);
		if (isStartDelay) Invoke("SetupStartDelay", StartDelay);
		else canStart = true;
		if (!isIn) {
			if (!FadeOutAfterCollision)
				Invoke("SetupFadeOutDelay", FadeOutDelay);
			oldAlpha = oldColor.a;
		}
	}

	void OnEnable()
	{
		if (isInitialized) InitDefaultVariables();
	}

	private void SetupStartDelay()
	{
		canStart = true;
	}

	private void SetupFadeOutDelay()
	{
		canStartFadeOut = true;
	}

	private void Update()
	{
		if (!canStart)
			return;

		if ( UseHideStatus)
		{
			if ( fadeInComplited)
				fadeInComplited = false;
			if (fadeOutComplited)
				fadeOutComplited = false;
		}

		if (UseHideStatus) {
			if (isIn) {
				if ( !fadeInComplited)
					FadeIn();
			}
			if (isOut) {
				if ( !fadeOutComplited)
					FadeOut();
			}
		}
		else if (!FadeOutAfterCollision) {
			if (isIn) {
				if (!fadeInComplited)
					FadeIn();
			}
			if (isOut && canStartFadeOut) {
				if (!fadeOutComplited)
					FadeOut();
			}
		}
		else {
			if (isIn) {
				if (!fadeInComplited)
					FadeIn();
			}
			if (isOut &&  canStartFadeOut && !fadeOutComplited)
				FadeOut();
		}
	}


	private void FadeIn()
	{
		alpha = oldAlpha + Time.deltaTime / FadeInSpeed;
		if (alpha >= oldColor.a) {
			fadeInComplited = true; 
			alpha = oldColor.a;
			foreach(Transform tran in GetComponentsInChildren<Transform>())
				tran.gameObject.layer = oldLayer;
			Invoke("SetupFadeOutDelay", FadeOutDelay);
		} 
		currentColor.a = alpha;
		for(int i = 0;i< matLength;i++)
		  mats[i].SetColor(ShaderColorName, currentColor);
		oldAlpha = alpha;
	}

	private void FadeOut()
	{
		alpha = oldAlpha - Time.deltaTime / FadeOutSpeed;
		if (alpha <= 0) {
			alpha = 0;
			fadeOutComplited = true;
		}
		currentColor.a = alpha;
		for(int i = 0;i< matLength;i++)
			mats[i].SetColor(ShaderColorName, currentColor);
		oldAlpha = alpha;
	}

	#endregion
}