using UnityEngine;
using UnityEditor;  

public class PostModelprocessor : AssetPostprocessor
{

    public void OnPreprocessModel()
    {
        if (!assetPath.Contains("Hero"))
        {
           // ModelImporter modelImporter = (ModelImporter)assetImporter;

           // modelImporter.isReadable = false;
        }

    }
  
}
