/********************************************************************************
** auth： yanwei
** date： 2017-2-17
** desc： boss高亮效果 。
*********************************************************************************/
using UnityEngine;
using System.Collections;

public class BeHitHighlightEffect : Effect {

	private string ShaderColorName = "_Color";
	private Renderer[] renders;
	private int matLength = 0;
    private int rendersLength = 0;
	private float kTime = 0;
	private bool bBffect;
	private float kBurationTime = 0.15f;

	void MaterialsInit () 
	{
		renders = transform.GetComponentsInChildren<Renderer>();
		if(renders!=null) 
		{
            rendersLength = renders.Length;
            matLength = renders[0].materials.Length;
		}
        
		instanceMat = ResourceManager.GetMaterial("Effect/BeHitHighlight");

	}

	private bool ExceptRenderer(Renderer renderer)
	{
		if(renderer is SpriteRenderer||renderer is ParticleSystemRenderer||renderer.gameObject.layer == LayerMask.NameToLayer("Default"))
			return true;
		else
			return false;
	}

    public override void OnUpdate(float deltaTime) 
	{
		if (bBffect) {
            kTime += deltaTime;
			if(kTime > kBurationTime)
			{
				bBffect = false;
				kTime = 0f;
				RevertEffect();
				RevertComplited = true;
			}
		}

	}

    public override void SetEffect(params object[] args)
	{
		MaterialsInit () ;
        for (int i = 0; i < rendersLength; i++)
		{
			if(ExceptRenderer(renders[i]))  continue; 
			var materials = renders[i].materials;
			var length = materials.Length + 1;
			var newMaterials = new Material[length];
			materials.CopyTo(newMaterials,0);

			newMaterials[length - 1] = instanceMat;
			renders[i].materials = newMaterials;
		}
		bBffect = true;
	}

	public override void  OnRecycle()
	{
		RevertEffect();
	}

	public override void RevertEffect()
	{
        for (int i = 0; i < rendersLength; i++)
		{
			if(ExceptRenderer(renders[i]) ) continue; 
			var materials = renders[i].materials;
            if (materials.Length == matLength) continue;
            var newMaterials = new Material[materials.Length - 1];
			for(int j =0;j< materials.Length -1 ;j++)
				newMaterials[j] = materials[j];

			renders[i].materials = newMaterials;

		}
	}
}
