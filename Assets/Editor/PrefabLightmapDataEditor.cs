using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(PrefabLightmapData))]
public class PrefabLightmapDataEditor : Editor
{
    
    private PrefabLightmapData prefabLightmap { get { return target as PrefabLightmapData; } }
    public override void OnInspectorGUI()
    {
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("LoadLightMap"))
        {
            PrefabLightmapData[] prefabLightmaps = FindObjectsOfType(typeof(PrefabLightmapData)) as PrefabLightmapData[];
            foreach (PrefabLightmapData prefabLightmap in prefabLightmaps)
            {
                prefabLightmap.LoadLightmap();
            } 
            
        }
        EditorGUILayout.EndHorizontal();
    }
}