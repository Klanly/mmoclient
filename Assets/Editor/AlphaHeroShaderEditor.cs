using UnityEngine;
using System.Collections;
using UnityEditor;

public class AlphaHeroShaderEditor : ShaderGUI
{
	public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
		base.OnGUI(materialEditor,properties);
		MaterialProperty AlphaMap = ShaderGUI.FindProperty("_Alpha", properties);
		bool bAlphaMapEnabled = AlphaMap.textureValue != null;

        Material material = materialEditor.target as Material;
		if (bAlphaMapEnabled)
			material.EnableKeyword("UNITY_ALPHA");
        else
			material.DisableKeyword("UNITY_ALPHA");
    }

}
