using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.IO;
using System.Reflection;

public class MaterialTextureForETC1
{

    private static string defaultWhiteTexPath_relative = "Assets/Textures/Default_Alpha.png";
    private static Texture2D defaultWhiteTex = null;
    private static string currentRgbTex = null;
    private static string currentAlphaTex = null;

    [MenuItem("EffortForETC1/Depart RGB and Alpha Channel")]
    static void SeperateAllTexturesRGBandAlphaChannel()
    {
        Debug.Log("Start Departing.");
        if (!GetDefaultWhiteTexture())
        {
            return;
        }
        foreach (Object obj in Selection.objects)
        {
            string selectionPath = AssetDatabase.GetAssetPath(obj);
            if (!string.IsNullOrEmpty(selectionPath) && IsTextureFile(selectionPath) && !IsTextureConverted(selectionPath))   //full name  
            {
                SeperateRGBAandlphaChannel(selectionPath);
            }
        }
           //Refresh to ensure new generated RBA and Alpha textures shown in Unity as well as the meta file
        Debug.Log("Finish Departing.");
    }

    [MenuItem("EffortForETC1/Set Texture ImportSetting")]
    static void SetTexturesImportSetting()
    {
        foreach (Object obj in Selection.objects)
        {
            string selectionPath = AssetDatabase.GetAssetPath(obj);
            ReImportAsset(selectionPath, 2048, 2048);
        }
        AssetDatabase.Refresh();    //Refresh to ensure new generated RBA and Alpha textures shown in Unity as well as the meta file
    }
    private static bool IsIncludeSlected(string ObjectName)
    {
         Object[] objects = Selection.objects;
        for (int iter = 0; iter < objects.Length; ++iter)
        {
            if (ObjectName == objects[iter].name)
                return true;
            else continue;
            
        }
        return false;
    }
    #region process texture

   public static void SeperateRGBAandlphaChannel(string _texPath)
    {
        System.Type t = System.Type.GetType("UnityEngine.DefaultAsset,UnityEngine");

        string assetRelativePath = _texPath;

        SetTextureReadableEx(assetRelativePath);    //set readable flag and set textureFormat TrueColor
        Texture2D sourcetex = AssetDatabase.LoadAssetAtPath(assetRelativePath, typeof(Texture2D)) as Texture2D;  //not just the textures under Resources file  
        if (!sourcetex)
        {
            Debug.LogError("Load Texture Failed : " + assetRelativePath);
            return;
        }

        TextureImporter ti = null;
        try
        {
            ti = (TextureImporter)TextureImporter.GetAtPath(assetRelativePath);
        }
        catch
        {
            Debug.LogError("Load Texture failed: " + assetRelativePath);
            return;
        }
        if (ti == null)
        {
            return;
        }
        bool bGenerateMipMap = ti.mipmapEnabled;    //same with the texture import setting      

        Texture2D rgbTex = new Texture2D(sourcetex.width, sourcetex.height, TextureFormat.RGB24, bGenerateMipMap);
      //  rgbTex.SetPixels(sourcetex.GetPixels());

        Texture2D mipMapTex = new Texture2D(sourcetex.width, sourcetex.height, TextureFormat.RGBA32, true);  //Alpha Channel needed here
        mipMapTex.SetPixels(sourcetex.GetPixels());
        mipMapTex.Apply();
        Color[] colors2rdLevel = mipMapTex.GetPixels();   //Second level of Mipmap
        Color[] colorsAlpha = new Color[colors2rdLevel.Length];

        if (colors2rdLevel.Length != (mipMapTex.width * mipMapTex.height))
        {
            Debug.LogError("Size Error.");
            return;
        }
        for (int i = 0; i < sourcetex.width; ++i)
            for (int j = 0; j < sourcetex.height; ++j)
            {
                Color color = sourcetex.GetPixel(i, j);
                Color rgbColor = color;
                  rgbTex.SetPixel(i, j, rgbColor);
            }  
        bool bAlphaExist = false;
        for (int i = 0; i < colors2rdLevel.Length; ++i)
        {
            colorsAlpha[i].r = colors2rdLevel[i].a;
            colorsAlpha[i].g = colors2rdLevel[i].a;
            colorsAlpha[i].b = colors2rdLevel[i].a;

            if (!Mathf.Approximately(colors2rdLevel[i].a, 1.0f))
            {
                bAlphaExist = true;
            }
        }
        Texture2D alphaTex = null;
        if (bAlphaExist)
        {
            alphaTex = new Texture2D(sourcetex.width , sourcetex.height , TextureFormat.RGB24, bGenerateMipMap);
        }
        else
        {
            alphaTex = new Texture2D(defaultWhiteTex.width, defaultWhiteTex.height, TextureFormat.RGB24, false);
        }

        alphaTex.SetPixels(colorsAlpha);

        rgbTex.Apply();
        alphaTex.Apply();
        
        byte[] bytes = rgbTex.EncodeToPNG();
        assetRelativePath = GetRGBTexPath(_texPath);
        File.WriteAllBytes(assetRelativePath, bytes);
        byte[] alphabytes = alphaTex.EncodeToPNG();
        string alphaTexRelativePath = GetAlphaTexPath(_texPath);
        File.WriteAllBytes(alphaTexRelativePath, alphabytes);
        currentRgbTex = assetRelativePath;
        currentAlphaTex = alphaTexRelativePath;
        ReImportAsset(assetRelativePath, sourcetex.width, sourcetex.width);
        ReImportAsset(alphaTexRelativePath, sourcetex.width, sourcetex.width);
        AssetDatabase.Refresh(); 
    }

   static public Texture2D RGBTex
   {
       get { return AssetDatabase.LoadAssetAtPath(currentRgbTex, typeof(Texture2D)) as Texture2D;  }
   }
   static public Texture2D AlphaTex
   {
       get { return AssetDatabase.LoadAssetAtPath(currentAlphaTex, typeof(Texture2D)) as Texture2D; }
   }
    static void ReImportAsset(string path, int width, int height)
    {
        try
        {
            AssetDatabase.ImportAsset(path);

        }
        catch
        {
            Debug.LogError("Import Texture failed: " + path);
            return;
        }
        
        TextureImporter importer = null;
       
        try
        {
            importer = (TextureImporter)TextureImporter.GetAtPath(path);
        }
        catch
        {
            Debug.LogError("Load Texture failed: " + path);
            return;
        }
        if (importer == null)
        {
            return;
        }
        importer.maxTextureSize = Mathf.Max(width, height);
        importer.anisoLevel = 4;
        importer.mipmapEnabled = false;
        importer.isReadable = false;  //increase memory cost if readable is true
        importer.textureFormat = TextureImporterFormat.AutomaticCompressed;
        importer.textureType = TextureImporterType.Advanced;
        if (path.Contains("/UI/"))
        {
            importer.textureType = TextureImporterType.GUI;
        }
        AssetDatabase.ImportAsset(path);
    }


    static void SetTextureReadableEx(string _relativeAssetPath)    //set readable flag and set textureFormat TrueColor
    {
        TextureImporter ti = null;
        try
        {
            ti = (TextureImporter)TextureImporter.GetAtPath(_relativeAssetPath);
        }
        catch
        {
            Debug.LogError("Load Texture failed: " + _relativeAssetPath);
            return;
        }
        if (ti == null)
        {
            return;
        }
        ti.isReadable = true;
        ti.textureFormat = TextureImporterFormat.AutomaticTruecolor;      //this is essential for departing Textures for ETC1. No compression format for following operation.
        AssetDatabase.ImportAsset(_relativeAssetPath);
    }

    static bool GetDefaultWhiteTexture()
    {
        defaultWhiteTex = AssetDatabase.LoadAssetAtPath(defaultWhiteTexPath_relative, typeof(Texture2D)) as Texture2D;  //not just the textures under Resources file  
        if (!defaultWhiteTex)
        {
            Debug.LogError("Load Texture Failed : " + defaultWhiteTexPath_relative);
            return false;
        }
        return true;
    }

    #endregion

    #region string or path helper

    static bool IsTextureFile(string _path)
    {
        string path = _path.ToLower();
        return path.EndsWith(".psd") || path.EndsWith(".tga") || path.EndsWith(".png") || path.EndsWith(".jpg") || path.EndsWith(".bmp") || path.EndsWith(".tif") || path.EndsWith(".gif");
    }

    static bool IsTextureConverted(string _path)
    {
        return _path.Contains("_RGB.") || _path.Contains("_Alpha.");
    }

    static string GetRGBTexPath(string _texPath)
    {
        return GetTexPath(_texPath, "_RGB.");
    }

    static string GetAlphaTexPath(string _texPath)
    {
        return GetTexPath(_texPath, "_Alpha.");
    }

    static string GetTexPath(string _texPath, string _texRole)
    {
        string dir = System.IO.Path.GetDirectoryName(_texPath);
        string filename = System.IO.Path.GetFileNameWithoutExtension(_texPath);
        string result = dir + "/" + filename + _texRole + "png";
        return result;
    }

    static string GetRelativeAssetPath(string _fullPath)
    {
        _fullPath = GetRightFormatPath(_fullPath);
        int idx = _fullPath.IndexOf("Assets");
        string assetRelativePath = _fullPath.Substring(idx);
        return assetRelativePath;
    }

    static string GetRightFormatPath(string _path)
    {
        return _path.Replace("\\", "/");
    }

    #endregion
} 
