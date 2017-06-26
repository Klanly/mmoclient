using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System;

public class EditorMapExporter : ScriptableObject
{
    private static int vertexOffset = 0;
    private static string targetFolder = "Assets";
    private static StringBuilder sbLog = new StringBuilder();
    private static string geomsetFileName = "geomset.txt";

    private static void FlushLog()
    {
        if (!CreateTargetFolder())
            return;

        using (StreamWriter sw = new StreamWriter(targetFolder + "/" + "MapExporter.log", true))
        {
            sw.Write(sbLog.ToString());
        }
        sbLog = new StringBuilder();
    }

    private static string MeshToString(MeshFilter mf)
    {
        Mesh m = mf.sharedMesh;

        StringBuilder sb = new StringBuilder();

        sb.Append("g ").Append(mf.name).Append("\n");
        sb.Append("\n");
        foreach (Vector3 lv in m.vertices)
        {
            Vector3 wv = mf.transform.TransformPoint(lv);

            //This is sort of ugly - inverting x-component since we're in
            //a different coordinate system than "everyone" is "used to".
            sb.Append(string.Format("v {0} {1} {2}\n", -wv.x, wv.y, wv.z));
        }
        sb.Append("\n");

        for (int material = 0; material < m.subMeshCount; material++)
        {
            int[] triangles = m.GetTriangles(material);
            for (int i = 0; i < triangles.Length; i += 3)
            {
                //Because we inverted the x-component, we also needed to alter the triangle winding.
                sb.Append(string.Format("f {1} {0} {2}\n",
                    triangles[i] + 1 + vertexOffset, triangles[i + 1] + 1 + vertexOffset, triangles[i + 2] + 1 + vertexOffset));
            }
        }
        sb.Append("\n");

        vertexOffset += m.vertices.Length;

        return sb.ToString();
    }

    private static void Clear()
    {
        vertexOffset = 0;
    }

    private static void MeshesToFile(MeshFilter[] mf, string filename)
    {
        Clear();
        string folder = targetFolder;
        using (StreamWriter sw = new StreamWriter(folder + "/" + filename))
        {
            for (int i = 0; i < mf.Length; i++)
            {
                sw.Write(MeshToString(mf[i]));
            }
        }
        EditorUtility.DisplayDialog("Map exported", "Exported " + mf.Length + " objects to " + filename, "OK");
    }

    private static bool CreateTargetFolder()
    {
        try
        {
            System.IO.Directory.CreateDirectory(targetFolder);
        }
        catch
        {
            EditorUtility.DisplayDialog("Error!", "Failed to create target folder!", "OK");
            return false;
        }

        return true;
    }

    // 获取场景中的所有游戏对象, 选出所有NavigationStatic对象.
    // 静态光源等无MeshFilter的将被忽略.
    private static GameObject[] GetNavStaticObjects()
    {
        sbLog.Append("Get navigation static objects:\n");
        ArrayList navStaticObjList = new ArrayList();
        GameObject[] gos = (GameObject[])FindObjectsOfType(typeof(GameObject));
        foreach (GameObject go in gos)
        {
            // 暂无OffMeshLinkGeneration
            if (!GameObjectUtility.AreStaticEditorFlagsSet(go, StaticEditorFlags.NavigationStatic))
                continue;
            Component[] meshfilter = go.transform.GetComponents(typeof(MeshFilter));
            if (0 == meshfilter.Length)
                continue;

            navStaticObjList.Add(go);
            sbLog.AppendFormat("Name: {0}, MeshFilters: {1}\n", go.name, meshfilter.Length);
        }

        return (GameObject[])navStaticObjList.ToArray(typeof(GameObject));
    }

    // 获取场景中的所有游戏对象, 选出所有NavigationStatic对象.
    // 静态光源等无MeshFilter的将被忽略.
    private static MeshFilter[] GetMeshFilters(GameObject[] gos)
    {
        ArrayList mfList = new ArrayList();
        for (int i = 0; i < gos.Length; i++)
        {
            GameObject go = gos[i];
            Component[] meshfilter = go.transform.GetComponents(typeof(MeshFilter));
            for (int m = 0; m < meshfilter.Length; m++)
            {
                mfList.Add(meshfilter[m]);
            }
        }
        return (MeshFilter[])mfList.ToArray(typeof(MeshFilter));
    }

    [MenuItem("NavMesh/Export Map v4")]
    static void ExportWholeSelectionToSingle()
    {
        if (!CreateTargetFolder())
            return;

        sbLog.AppendFormat("NavMeshLayerNames:\n");
        string[] nmLayerNames = GameObjectUtility.GetNavMeshLayerNames();
        for (int i = 0; i < nmLayerNames.Length; i++)
        {
            sbLog.AppendFormat("{0}: {1}\n",
                                nmLayerNames[i],
                                GameObjectUtility.GetNavMeshLayerFromName(nmLayerNames[i]));
        }
        sbLog.Append("\n");

        //获取场景中的所有游戏对象, 选出所有NavigationStatic对象
        GameObject[] gos = GetNavStaticObjects();
        MeshFilter[] mf = GetMeshFilters(gos);
        string objFileName = GetObjSaveFileName(mf.Length);
        MeshesToFile(mf, objFileName);
        SaveGeomsetFile(mf, objFileName);

        FlushLog();
    }

    private static string GetObjSaveFileName(int exportedObjects)
    {
        string filename = EditorApplication.currentScene + "_" + exportedObjects;
        int stripIndex = filename.LastIndexOf('/');//FIXME: Should be Path.PathSeparator
        if (stripIndex >= 0)
            filename = filename.Substring(stripIndex + 1).Trim();
        return filename + ".obj";
    }

    private static void SaveGeomsetFile(MeshFilter[] mf, string objFileName)
    {
        using (StreamWriter sw = new StreamWriter(targetFolder + "/" + geomsetFileName))
        {
            sw.Write("# Obj file.\n");
            sw.Write("f " + objFileName + "\n\n");
            // 暂无 Offmesh connector
            // Convex volumes
            ConvexVolumes cvs = new ConvexVolumes(mf);
            sw.Write(cvs.ToString());
        }
    }

    class ConvexVolumes
    {
        private ArrayList cvList = new ArrayList();

        public ConvexVolumes(MeshFilter[] mf)
        {
            for (int i = 0; i < mf.Length; i++)
            {
                cvList.Add(new ConvexVolume(mf[i]));
            }
        }

        public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("# Convex volumes.\n");
            sb.Append("# v nVertex area hmin hmax\n");
            sb.Append("# Area:\n");
            string[] nmLayerNames = GameObjectUtility.GetNavMeshLayerNames();
            for (int i = 0; i < nmLayerNames.Length; i++)
            {
                sb.AppendFormat("#\t{0}: {1}\n",
                                 GameObjectUtility.GetNavMeshLayerFromName(nmLayerNames[i]),
                                 nmLayerNames[i]);
            }
            sb.Append("\n");

            foreach (ConvexVolume cv in cvList)
            {
                sb.Append(cv.ToString() + "\n");
            }
            return sb.ToString();
        }
    }

    class ConvexVolume
    {
        private string name;
        private int areaType;
        private float minh;
        private float maxh;
        private ArrayList vertList;

        public ConvexVolume(MeshFilter mf)
        {
            name = mf.gameObject.name;
            areaType = GameObjectUtility.GetNavMeshLayer(mf.gameObject);
            sbLog.AppendFormat("ConvexVolume: name = {0}, area = {1}\n",
                                mf.gameObject.name, areaType);
            Vector3[] allVertices = GetAllVertices(mf);
            GetHeight(allVertices);
            ConvexHull(allVertices);
        }

        public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("# {0}\n", name);
            sb.AppendFormat("v {0} {1} {2} {3}\n", vertList.Count, areaType, minh, maxh);
            foreach (Vector3 v in vertList)
            {
                sb.AppendFormat("{0} {1} {2}\n", v.x, v.y, v.z);
            }
            return sb.ToString();
        }

        private Vector3[] GetAllVertices(MeshFilter mf)
        {
            Mesh m = mf.sharedMesh;
            ArrayList vertList = new ArrayList();

            foreach (Vector3 lv in m.vertices)
            {
                Vector3 wv = mf.transform.TransformPoint(lv);
                //This is sort of ugly - inverting x-component
                Vector3 wv2 = new Vector3(-wv.x, wv.y, wv.z);
                vertList.Add(wv2);
            }
            return (Vector3[])vertList.ToArray(typeof(Vector3));
        }

        private void ConvexHull(Vector3[] v)
        {
            vertList = new ArrayList();

            // Find lower-leftmost point.
            int org_hull = 0;
            for (int h = 1; h < v.Length; ++h)
                if (CompPoint(v[h], v[org_hull]))
                    org_hull = h;

            // Gift wrap hull.
            int endpt = 0;
            int hull = org_hull;
            int count = 0;
            do
            {
                count++;
                if (count > 999999)
                {
                    EditorUtility.DisplayDialog("Convex Hull Error", "Something is wrong!!!", "OK");
                    break;
                }

                vertList.Add(v[hull]);
                // sbLog.AppendFormat ("Got hull {0} : {1}\n", hull, v[hull].ToString ());
                endpt = 0;
                for (int j = 1; j < v.Length; ++j)
                    if (endpt == hull || IsLeft(v[hull], v[endpt], v[j]))
                        endpt = j;
                hull = endpt;
            }
            while (endpt != org_hull && count <= 24);
            FlushLog();
        }

        // Returns true if 'c' is left of line 'a'-'b'.
        private bool IsLeft(Vector3 a, Vector3 b, Vector3 c)
        {
            float u1 = b.x - a.x;
            float v1 = b.z - a.z;
            float u2 = c.x - a.x;
            float v2 = c.z - a.z;
            return u1 * v2 - v1 * u2 < 0;
        }

        // Returns true if 'a' is more lower-left than 'b'.
        private bool CompPoint(Vector3 a, Vector3 b)
        {
            if (a.x < b.x) return true;
            if (a.x > b.x) return false;
            if (a.z < b.z) return true;
            if (a.z > b.z) return false;
            return false;
        }

        private void GetHeight(Vector3[] vertices)
        {
            minh = float.MaxValue;
            maxh = float.MinValue;
            foreach (Vector3 v in vertices)
            {
                if (minh > v.y)
                    minh = v.y;
                if (maxh < v.y)
                    maxh = v.y;
            }
        }
    }
}
