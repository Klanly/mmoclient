#if UNITY_EDITOR
using UnityEngine;
using System.IO;
using System.Text;
using UnityEditor;
using System.Collections.Generic;
using UnityEditor.Callbacks;
using UnityEditor.SceneManagement;
using System.Reflection;
using System.Linq;

public enum ScriptType
{
    eLua = 0,
    eCSharp = 1
}
public class BindView
{
    public static bool AutoBindView { get; set; }

    static readonly string Tag = "@";   // 有tag标记才能生成gameobject
    //static string ResourcePath = "Assets/Resources/";
    //static string UIPrefabPath = "UI/Prefabs/";
    //public static string UICSViewPath = "UI/Views/";
    public static string UILuaViewPath = "Assets/TLBY/Lua/UI/View/";

    static readonly string bindViewKey = "__bind_view_key__";

    static string luaViewBaseClassName = "LuaViewBase";
    static string csViewBaseClassName = "View";

    static BindView()
    {
        AutoBindView = true;
    }

    //[MenuItem("Tools/Gen View Files", false, 12)]
    //static void GenViewFile()
    //{
    //    if (!Directory.Exists(ResourcePath + UIPrefabPath))
    //    {
    //        return;
    //    }
    //    string[] prefabFiles = Directory.GetFiles(ResourcePath + UIPrefabPath, "*.prefab");
    //    for (int i = 0; i < prefabFiles.Length; i++)
    //    {
    //        string fullFileName = prefabFiles[i];
    //        fullFileName = fullFileName.Replace('\\', '/');
    //        string fileName = Path.GetFileNameWithoutExtension(fullFileName);
    //        GameObject prefab = Resources.Load(UIPrefabPath + fileName) as GameObject;
    //        if (prefab == null)
    //        {
    //            Debug.LogError("Load prefab failed! path = " + (UIPrefabPath + fileName));
    //            continue;
    //        }

    //        List<GameObject> tagChildren = new List<GameObject>();
    //        GetTagChildren(prefab, ref tagChildren);

    //        GenerateCSViewFile(prefab.name, tagChildren);

    //        EditorUtility.DisplayProgressBar("Generating views", "正在生成" + fileName, (float)i/prefabFiles.Length);
    //    }
    //    EditorUtility.ClearProgressBar();
    //    AssetDatabase.Refresh();
    //}

    public static void GenerateView(string assetPath, ScriptType eType)
    {
        string filename = assetPath.Replace("Assets/Resources/", string.Empty).Replace(".prefab", string.Empty);

        GameObject prefab = Resources.Load(filename) as GameObject;
        if (prefab == null)
        {
            Debug.LogError("Load prefab failed! path = " + (filename));
            return;
        }
        List<GameObject> tagChildren = new List<GameObject>();
        GetTagChildren(prefab, ref tagChildren);

        if (eType == ScriptType.eCSharp)
        {
            //GenerateCSViewFile(prefab.name, tagChildren);
            //if (AutoBindView)
            //{
            //    //保留绑定数据
            //    PlayerPrefs.SetString(bindViewKey, prefab.name + "|" + prefab.GetInstanceID() + "|" + eType.ToString());
            //}
        }
        else if (eType == ScriptType.eLua)
        {
            GenerateLuaViewFile(prefab.name, tagChildren);
            if (AutoBindView)
            {
                BindLuaScript(prefab.name, prefab.GetInstanceID());
            }
        }
        AssetDatabase.Refresh();
    }

    static void GetTagChildren(GameObject parent, ref List<GameObject> children)
    {
        if (parent != null)
        {
            for (int i = 0; i < parent.transform.childCount; i++)
            {
                GameObject child = parent.transform.GetChild(i).gameObject;
                string childName = child.name;
                if (childName.StartsWith(Tag))
                {
                    children.Add(child);
                }
                GetTagChildren(child, ref children);
            }
        }        
    }

    //static string GenerateCSViewFile(string className, List<GameObject> children) {
    //    StringBuilder sb = new StringBuilder();
    //    sb.AppendLine("/********************* auto generate code ********************/");
    //    sb.AppendLine("using UnityEngine;");
    //    sb.AppendFormat("\r\npublic class {0} : {1}\r\n", className, csViewBaseClassName);
    //    sb.AppendLine("{");

    //    // 变量声明
    //    for (int i = 0; i < children.Count; i++)
    //    {
    //        string childName = GetChildName(children[i]);
    //        //sb.AppendLine("\t[HideInInspector]");            
    //        sb.AppendFormat("\tpublic GameObject {0};\r\n", childName);
    //    }

    //    sb.AppendLine("\r\n\tvoid Awake()");
    //    sb.AppendLine("\t{");
    //    for (int i = 0; i < children.Count; i++)
    //    {
    //        string childName = GetChildName(children[i]);
    //        string childPath = GetChildPath(children[i]);
    //        sb.AppendFormat("\t\t{0} = transform.FindChild(\"{1}\").gameObject;\r\n", childName, childPath);
    //    }
    //    sb.AppendLine("\t}");
    //    sb.AppendLine("}");

    //    Directory.CreateDirectory(UICSViewPath);
    //    string file = UICSViewPath + className + ".cs";
    //    System.Text.UTF8Encoding utf8 = new System.Text.UTF8Encoding(false);
    //    using (StreamWriter textWriter = new StreamWriter(file, false, utf8))
    //    {
    //        textWriter.Write(sb.ToString());
    //        textWriter.Flush();
    //        textWriter.Close();
    //    }
    //    return file;
    //}

    static string GenerateLuaViewFile(string className, List<GameObject> children)
    {
        StringBuilder sb = new StringBuilder();
        sb.AppendLine("----------------------- auto generate code --------------------------");
        sb.AppendLine("require \"UI/View/LuaViewBase\"");
        sb.AppendLine();
        sb.AppendFormat("local function Create{0}()\r\n", className);
        sb.AppendLine("\tlocal self = CreateViewBase();");
        sb.AppendLine("\tself.Awake = function()");
        for (int i = 0; i < children.Count; i++)
        {
            string childName = GetChildName(children[i]);
            string childPath = GetChildPath(children[i]);
            sb.AppendFormat("\t\tself.{0} = self.transform:FindChild(\"{1}\").gameObject;\r\n", childName, childPath);
        }
        sb.AppendLine("\tend");
        sb.AppendLine("\treturn self;");
        sb.AppendLine("end");
        sb.AppendFormat("{0} = {1} or Create{2}();\r\n", className, className, className);

        Directory.CreateDirectory(UILuaViewPath);
        string file = UILuaViewPath + className + ".lua";

        System.Text.UTF8Encoding utf8 = new System.Text.UTF8Encoding(false);
        using (StreamWriter textWriter = new StreamWriter(file, false, utf8))
        {
            textWriter.Write(sb.ToString());
            textWriter.Flush();
            textWriter.Close();
        }
        return file;
    }

    static string GetChildName(GameObject child)
    {
        string name = child.name;
        name = name.Substring(1); // 去掉@符号
        return name;
    }
    
    static string GetChildPath(GameObject child)
    {
        string path = child.name;
        GameObject go = child;
        while (go.transform.parent != null && go.transform.parent.parent != null)
        {
            path = go.transform.parent.name + "/" + path;
            go = go.transform.parent.gameObject;
        }
        return path;
    }

    //[DidReloadScripts]
    static void OnReloadScripts()
    {
        CheckNeedBindCSScript();
    }

    /// <summary>
    /// 编译完后检查是否需要绑定C#脚本
    /// </summary>
    static void CheckNeedBindCSScript()
    {
        if (!PlayerPrefs.HasKey(bindViewKey))
        {
            return;
        } 
        string text = PlayerPrefs.GetString(bindViewKey);

        string[] data = text.Split('|');
        string name = data[0];
        int instanceID = int.Parse(data[1]);
        string scriptType = data[2];
        if (scriptType == ScriptType.eCSharp.ToString())
        {
            BindCSharpScript(name, instanceID);
        }
        PlayerPrefs.DeleteKey(bindViewKey);
    }

    static void BindCSharpScript(string className, int prefabInstanceID)
    {
        //GameObject uiGameObject = EditorUtility.InstanceIDToObject(prefabInstanceID) as GameObject;
        //if (uiGameObject == null)
        //{
        //    Debug.LogWarning("BindCSharpScript失败，因为load prefabInstanceID失败 prefabInstanceID＝" + prefabInstanceID);
        //    return;
        //}
        //System.Type myUIClass = typeof(LoginMain).Assembly.GetType(className);
        //if (myUIClass == null)
        //{
        //    Debug.LogWarning("BindCSharpScript失败，因为获取className失败 className＝" + className);
        //    return;
        //}

        //Component com = uiGameObject.GetComponent(className);
        //if (com != null)
        //{
        //    GameObject.DestroyImmediate(com);
        //}
        //uiGameObject.AddComponent(myUIClass);
        //EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
    }

    static void BindLuaScript(string className, int prefabInstanceID)
    {
        GameObject uiGameObject = EditorUtility.InstanceIDToObject(prefabInstanceID) as GameObject;

        LuaBehaviour com = uiGameObject.GetComponent<LuaBehaviour>();
        if (com == null)
        {
            com = uiGameObject.AddComponent<LuaBehaviour>();
        }
        com.FullPath = UILuaViewPath + className + ".lua";
        com.FullPath = com.FullPath.Replace("Assets/TLBY/Lua/", string.Empty);
        EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
        //GameObject.DestroyImmediate(uiGameObject);
    }
}

[CustomEditor(typeof(RectTransform))]
public class prefabInspector : DecoratorEditor
{
    public prefabInspector(): base("RectTransformEditor"){ }
    public override void OnInspectorGUI()
    {
        RectTransform rect = target as RectTransform;
        if (rect == null)
        {
            base.OnInspectorGUI();
            return;
        }
        string assetPath = AssetDatabase.GetAssetPath(rect.gameObject);
        string asset = PsdLayoutTool.PsdImporter.GetRelativePath(ResDefine.GetResPath(EResType.eResUI));

        if (assetPath.Contains(asset))
        {
            base.OnInspectorGUI();

            GUILayout.Space(3);
            GUILayout.Box(string.Empty, GUILayout.Height(1), GUILayout.MaxWidth(Screen.width - 30));
            GUILayout.Space(3);
            GUIContent autoBind = new GUIContent("autoBindView", "auto bind view to prefab");
            BindView.AutoBindView = EditorGUILayout.Toggle(autoBind, BindView.AutoBindView);

            //if (GUILayout.Button("Generate CS View Script"))
            //{
            //    string prefabFullPath = GetPrefabFullPath(assetPath);
            //    if (!System.IO.File.Exists(prefabFullPath))
            //    {
            //        UnityEditor.EditorUtility.DisplayDialog("提示", "没有找到prefab文件，请先生成prefab", "确定");
            //        return;
            //    }
            //    BindView.GenerateView(assetPath, ScriptType.eCSharp);
            //}
            //GUILayout.Space(3);

            if (GUILayout.Button("Generate Lua View Script"))
            {
                BindView.GenerateView(assetPath, ScriptType.eLua);
            }
            if (GUILayout.Button("Delete bind Script"))
            {
                //string CSAssetPath = BindView.UICSViewPath + System.IO.Path.GetFileNameWithoutExtension(assetPath);
                //bool ret = AssetDatabase.DeleteAsset(CSAssetPath + ".cs");

                string LuaAssetPath = BindView.UILuaViewPath + System.IO.Path.GetFileNameWithoutExtension(assetPath);
                bool ret = AssetDatabase.DeleteAsset(LuaAssetPath + ".lua");
                if (ret)
                {
                    AssetDatabase.Refresh();
                }
            }
            if (GUILayout.Button("Delete Repeat sprites"))
            {
                PsdLayoutTool.PsdImporter.DeleteCurrentPsdRepeatSprites(System.IO.Path.GetFileNameWithoutExtension(assetPath), false);
            }
        }
        else
        {
            base.OnInspectorGUI();
        }  
    }
    //string GetCSScriptFullPath(string assetPath)
    //{
    //    string scriptName = System.IO.Path.GetFileNameWithoutExtension(assetPath);
    //    return BindView.UICSViewPath + scriptName + ".cs";
    //}

    //string GetLuaScriptFullPath(string assetPath)
    //{
    //    string scriptName = System.IO.Path.GetFileNameWithoutExtension(assetPath);
    //    return BindView.UILuaViewPath + scriptName + ".lua";
    //}
}

public abstract class DecoratorEditor : Editor
{
    // empty array for invoking methods using reflection
    private static readonly object[] EMPTY_ARRAY = new object[0];

    #region Editor Fields

    /// <summary>
    /// Type object for the internally used (decorated) editor.
    /// </summary>
    private System.Type decoratedEditorType;

    /// <summary>
    /// Type object for the object that is edited by this editor.
    /// </summary>
    private System.Type editedObjectType;

    private Editor editorInstance;

    #endregion

    private static Dictionary<string, MethodInfo> decoratedMethods = new Dictionary<string, MethodInfo>();

    private static Assembly editorAssembly = Assembly.GetAssembly(typeof(Editor));

    protected Editor EditorInstance
    {
        get
        {
            if (editorInstance == null && targets != null && targets.Length > 0)
            {
                editorInstance = Editor.CreateEditor(targets, decoratedEditorType);
            }

            if (editorInstance == null)
            {
                Debug.LogError("Could not create editor !");
            }

            return editorInstance;
        }
    }

    public DecoratorEditor(string editorTypeName)
    {
        this.decoratedEditorType = editorAssembly.GetTypes().Where(t => t.Name == editorTypeName).FirstOrDefault();

        Init();

        // Check CustomEditor types.
        var originalEditedType = GetCustomEditorType(decoratedEditorType);

        if (originalEditedType != editedObjectType)
        {
            throw new System.ArgumentException(
                string.Format("Type {0} does not match the editor {1} type {2}",
                          editedObjectType, editorTypeName, originalEditedType));
        }
    }

    private System.Type GetCustomEditorType(System.Type type)
    {
        var flags = BindingFlags.NonPublic | BindingFlags.Instance;

        var attributes = type.GetCustomAttributes(typeof(CustomEditor), true) as CustomEditor[];
        var field = attributes.Select(editor => editor.GetType().GetField("m_InspectedType", flags)).First();

        return field.GetValue(attributes[0]) as System.Type;
    }

    private void Init()
    {
        var flags = BindingFlags.NonPublic | BindingFlags.Instance;

        var attributes = this.GetType().GetCustomAttributes(typeof(CustomEditor), true) as CustomEditor[];
        var field = attributes.Select(editor => editor.GetType().GetField("m_InspectedType", flags)).First();

        editedObjectType = field.GetValue(attributes[0]) as System.Type;
    }

    void OnDisable()
    {
        if (editorInstance != null)
        {
            DestroyImmediate(editorInstance);
        }
    }

    /// <summary>
    /// Delegates a method call with the given name to the decorated editor instance.
    /// </summary>
    protected void CallInspectorMethod(string methodName)
    {
        MethodInfo method = null;

        // Add MethodInfo to cache
        if (!decoratedMethods.ContainsKey(methodName))
        {
            var flags = BindingFlags.Instance | BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public;

            method = decoratedEditorType.GetMethod(methodName, flags);

            if (method != null)
            {
                decoratedMethods[methodName] = method;
            }
            else
            {
                Debug.LogError(string.Format("Could not find method {0}", method));
            }
        }
        else
        {
            method = decoratedMethods[methodName];
        }

        if (method != null)
        {
            method.Invoke(EditorInstance, EMPTY_ARRAY);
        }
    }

    public void OnSceneGUI()
    {
        CallInspectorMethod("OnSceneGUI");
    }

    protected override void OnHeaderGUI()
    {
        CallInspectorMethod("OnHeaderGUI");
    }

    public override void OnInspectorGUI()
    {
        EditorInstance.OnInspectorGUI();
    }

    public override void DrawPreview(Rect previewArea)
    {
        EditorInstance.DrawPreview(previewArea);
    }

    public override string GetInfoString()
    {
        return EditorInstance.GetInfoString();
    }

    public override GUIContent GetPreviewTitle()
    {
        return EditorInstance.GetPreviewTitle();
    }

    public override bool HasPreviewGUI()
    {
        return EditorInstance.HasPreviewGUI();
    }

    public override void OnInteractivePreviewGUI(Rect r, GUIStyle background)
    {
        EditorInstance.OnInteractivePreviewGUI(r, background);
    }

    public override void OnPreviewGUI(Rect r, GUIStyle background)
    {
        EditorInstance.OnPreviewGUI(r, background);
    }

    public override void OnPreviewSettings()
    {
        EditorInstance.OnPreviewSettings();
    }

    public override void ReloadPreviewInstances()
    {
        EditorInstance.ReloadPreviewInstances();
    }

    public override Texture2D RenderStaticPreview(string assetPath, Object[] subAssets, int width, int height)
    {
        return EditorInstance.RenderStaticPreview(assetPath, subAssets, width, height);
    }

    public override bool RequiresConstantRepaint()
    {
        return EditorInstance.RequiresConstantRepaint();
    }

    public override bool UseDefaultMargins()
    {
        return EditorInstance.UseDefaultMargins();
    }
}

#endif