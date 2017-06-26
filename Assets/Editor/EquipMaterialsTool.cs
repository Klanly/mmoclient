using System.IO;
using UnityEditor;
using UnityEngine;

public class EquipMaterialsTool
{
    [MenuItem("Game/更新装备纹理资源")]
    public static void CreateMaterial()
    {
        string pngPath = "Assets/Picture/ItemIcon/";
        string matPath = "Assets/Resources/Materials/ItemMaterial/";
        if (Directory.Exists(matPath))
        {
            string[] files = Directory.GetFiles(matPath, "*.mat");
            for (int j = 0; j < files.Length; j++)
            {
                AssetDatabase.DeleteAsset(files[j]);
                string name = Path.GetFileNameWithoutExtension(files[j]);
                EditorUtility.DisplayProgressBar("删除旧资源", "deleting " + name, (float)j / files.Length);
            }
            EditorUtility.ClearProgressBar();
            //AssetDatabase.Refresh();
        }

        if (Directory.Exists(pngPath))
        {
            string[] files = Directory.GetFiles(pngPath, "*.png");
            for (int j = 0; j < files.Length; j++)
            {
                string name = files[j].Replace("\\", "/");
                Texture myTexture = AssetDatabase.LoadAssetAtPath(name, typeof(Texture2D)) as Texture2D;
                Material material = new Material(Shader.Find("Sprites/Default"));
                material.mainTexture = myTexture;
                string matName = Path.GetFileNameWithoutExtension(name);
                AssetDatabase.CreateAsset(material, matPath + matName + ".mat");
                EditorUtility.DisplayProgressBar("添加新资源", "creating " + matName, (float)j / files.Length);
            }
            EditorUtility.ClearProgressBar();
            AssetDatabase.Refresh();

        }

    }
}
