using UnityEngine;
using UnityEditor;

public class UnlitTextureShaderGUI : ShaderGUI
{
	protected MaterialEditor editor;
	protected Material material;
	protected MaterialProperty[] properties;
	static GUIContent tempLabel = new GUIContent();

	MaterialProperty BeginProperty(string name)
	{
		MaterialProperty property = FindProperty(name, properties);
		EditorGUI.BeginChangeCheck();
		EditorGUI.showMixedValue = property.hasMixedValue;
		editor.BeginAnimatedCheck(property);
		return property;
	}

	bool EndProperty()
	{
		editor.EndAnimatedCheck();
		EditorGUI.showMixedValue = false;
		return EditorGUI.EndChangeCheck();
	}


	void DoTexture(string name, string label, System.Type type)
	{
		MaterialProperty property = BeginProperty(name);
		Rect rect = EditorGUILayout.GetControlRect(true, 60f);
		rect.width = EditorGUIUtility.labelWidth + 60f;
		tempLabel.text = label;
		Object tex = EditorGUI.ObjectField(rect, tempLabel, property.textureValue, type, false);
		if (EndProperty())
		{ property.textureValue = tex as Texture; }
	}

	protected void DoFloat(string name, string label)
	{
		MaterialProperty property = BeginProperty(name);
		Rect rect = EditorGUILayout.GetControlRect();
		rect.width = 225f;
		tempLabel.text = label;
		float value = EditorGUI.FloatField(rect, tempLabel, property.floatValue);
		if (EndProperty())
		{ property.floatValue = value; }
	}

	protected void DoTexture2D(string name, string label)
	{ DoTexture(name, label, typeof(Texture2D)); }

	protected void DoColor(string name, string label)
	{
		MaterialProperty property = BeginProperty(name);
		tempLabel.text = label;
		Color value = EditorGUI.ColorField(EditorGUILayout.GetControlRect(), tempLabel, property.colorValue);
		if (EndProperty())
		{ property.colorValue = value; }
	}

	protected bool DoToggle(string name, string label)
	{
		MaterialProperty property = BeginProperty(name);
		tempLabel.text = label;
		bool value = EditorGUILayout.Toggle(tempLabel, property.floatValue == 0f);
		if (EndProperty())
		{ property.floatValue = value ? 1f : 0f; }
		return value;
	}
	bool showAlpha = false;
	bool showGray = false;
	public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
	{
		editor = materialEditor;
		material = materialEditor.target as Material;
		this.properties = properties;
		DoColor("_Color","Color Tint");
		DoTexture2D("_MainTex","Base (RGB)");

		showAlpha =EditorGUILayout.Toggle("UseAlpha", showAlpha);
		if(showAlpha)
		{
			DoTexture2D("_AlphaTex","Alpha (RGB)");
			material.EnableKeyword("UNITY_Alpha");
		}
		else
		{
			material.DisableKeyword("UNITY_Alpha");
		}
		showGray = EditorGUILayout.Toggle("UseGray", showGray);
		if(showGray)
		{
			material.EnableKeyword("UNITY_GRAY");
		}
		else
		{
			material.DisableKeyword("UNITY_GRAY");
		}

	}
}
