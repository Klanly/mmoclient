/********************************************************************************
** auth： yanwei
** date： 2016-12-18
** desc： Effect基类 石化效果 。
*********************************************************************************/
using UnityEngine;
using System.Collections;

public class FossilisedEffect : Effect {

	public float FadeTimes = 0.65f;
	private string ShaderColorName = "_Color";
	private Renderer[] renders;
	private int matLength = 0;
	private bool isIn, isOut;
	private bool fadeInComplited;
	private float oldAlpha, alpha;
	private Color oldColor, currentColor;

	void MaterialsInit () 
	{
		renders = transform.GetComponentsInChildren<Renderer>();
		if(renders!=null) 
		{
			matLength = renders.Length;
		}
		oldAlpha = 0;
		instanceMat = ResourceManager.GetMaterial("Effect/Fossilised");
	
	}
    public override void SetEffect(params object[] args)
	{
		MaterialsInit () ;
		for(int i = 0;i<matLength;i++)
		{
			if(ExceptRenderer(renders[i]))  continue; 
			var materials = renders[i].materials;
			var length = materials.Length + 1;
			var newMaterials = new Material[length];
			materials.CopyTo(newMaterials,0);

			newMaterials[length - 1] = instanceMat;
			renders[i].materials = newMaterials;
			oldColor = newMaterials[1].GetColor(ShaderColorName);
			currentColor = oldColor;
		}
		isIn = true;

	}
	public override void RevertEffect()
	{
		isOut = true;
	}

	public override void  OnRecycle()
	{
		for(int i = 0;i<matLength;i++)
		{
			if(ExceptRenderer(renders[i])) continue; 
			var materials = renders[i].materials;
			var newMaterials = new Material[ materials.Length -1];
			for(int j =0;j< materials.Length -1 ;j++)
				newMaterials[j] = materials[j];


			newMaterials[0].DisableKeyword("UNITY_GRAY");
			newMaterials[0].SetFloat("_UseGray",0.0f);
			renders[i].materials = newMaterials;
		}

	}

	// Update is called once per frame
	public override void OnUpdate (float deltaTime) 
	{
		if (isIn) {
			if ( !fadeInComplited)
                FadeIn(deltaTime);
		}
		if (isOut) {
			if ( !RevertComplited)
                FadeOut(deltaTime);
		}
	}

	private bool ExceptRenderer(Renderer renderer)
	{
		if(renderer is SpriteRenderer||renderer is ParticleSystemRenderer||renderer.gameObject.layer == LayerMask.NameToLayer("Default"))
			return true;
		else
			return false;
	}


    private void FadeIn(float deltaTime)
	{
        alpha = oldAlpha + deltaTime / FadeTimes;
		if (alpha >= oldColor.a) {
			fadeInComplited = true; 
			alpha = oldColor.a;

		} 
		currentColor.a = alpha;
		for(int i = 0;i<matLength;i++)
		{
			if(ExceptRenderer(renders[i]))continue; 
			var materials = renders[i].materials;
			materials[1].SetColor(ShaderColorName, currentColor);
			if(fadeInComplited)
			{
				materials[0].EnableKeyword("UNITY_GRAY");
				materials[0].SetFloat("_UseGray",1.0f);
			}

		}
		oldAlpha = alpha;
	}

    private void FadeOut(float deltaTime)
	{
        alpha = oldAlpha - deltaTime / FadeTimes;
		if (alpha <= 0) {
			alpha = 0;
			RevertComplited = true;
		}
		currentColor.a = alpha;
		for(int i = 0;i<matLength;i++)
		{
			if(ExceptRenderer(renders[i])) continue; 
			var materials = renders[i].materials;
			materials[1].SetColor(ShaderColorName, currentColor);
			if(RevertComplited)
			{
				materials[0].DisableKeyword("UNITY_GRAY");
				materials[0].SetFloat("_UseGray",0.0f);

			}

		}
		oldAlpha = alpha;
		if(RevertComplited)
		{
			for(int i = 0;i<matLength;i++)
			{
				if(ExceptRenderer(renders[i])) continue; 
				var materials = renders[i].materials;
				var newMaterials = new Material[ materials.Length -1];
				for(int j =0;j< materials.Length -1 ;j++)
					newMaterials[j] = materials[j];

				renders[i].materials = newMaterials;

			}
		}
	}
}


public class Effect : MonoBehaviour
{
	protected Material instanceMat;
	public bool RevertComplited;
	public virtual void SetEffect(params object[] args) {}

	public virtual void RevertEffect(){}

    public virtual void OnUpdate(float deltaTime) { }

	public virtual void OnRecycle() {}


}