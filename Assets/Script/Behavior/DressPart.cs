using UnityEngine;
using System.Collections.Generic;

[System.Serializable]
public class SkinMeshInfo
{
    public List<Material> materials;
    public Mesh mesh;
    public List<string> bonesName;
}

public class DressPart : MonoBehaviour
{
    public SkinMeshInfo skinMeshInfo = new SkinMeshInfo();

    public static void ChangeClothes(GameObject root, params string[] dressInfos)
    {
        List<SkinMeshInfo> smiList = new List<SkinMeshInfo>();
        int num = 0;
        for (int i = 0; i < dressInfos.Length; i++)
        {
            if (dressInfos[i] == null || dressInfos[i] == "")
            {
                continue;
            }
            num++;
        }
        foreach (var dressInfo in dressInfos)
        {
            if(dressInfo == null || dressInfo == "")
            {
                continue;
            }
            ObjectPoolManager.NewObject(dressInfo, EResType.eResCharacter, obj => {
                var part = obj as GameObject;
                if (part == null) return;
                DressPart p = part.GetComponent<DressPart>();
                if (p == null) return;
                smiList.Add(p.skinMeshInfo);
                ObjectPoolManager.RecycleObject(part);
                if (smiList.Count == num)
                {
                    List<CombineInstance> combineInstances = new List<CombineInstance>();
                    List<Material> materials = new List<Material>();
                    List<Transform> bones = new List<Transform>();
                    Transform[] transforms = root.GetComponentsInChildren<Transform>();

                    foreach (var item in smiList)
                    {
                        for (int sub = 0; sub < item.mesh.subMeshCount; sub++)
                        {
                            CombineInstance ci = new CombineInstance();
                            ci.mesh = item.mesh;
                            ci.subMeshIndex = sub;
                            combineInstances.Add(ci);
                        }

                        foreach (string bone in item.bonesName)
                        {
                            foreach (Transform transform in transforms)
                            {
                                if (transform.name != bone) continue;
                                bones.Add(transform);
                                break;
                            }
                        }
                        materials.AddRange(item.materials);
                    }

                    SkinnedMeshRenderer r = root.GetComponent<SkinnedMeshRenderer>();
                    if (r == null) r = root.AddComponent<SkinnedMeshRenderer>();
                    r.bones = bones.ToArray();
                    r.materials = materials.ToArray();
                    r.sharedMesh = new Mesh();
                    r.sharedMesh.CombineMeshes(combineInstances.ToArray(), false, false);
                    root.SetActive(false);
                    root.SetActive(true);
                }
            });

        }
        
    }
}
