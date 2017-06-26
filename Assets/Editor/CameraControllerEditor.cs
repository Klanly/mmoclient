using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using System.Collections;
using System.Reflection;
using System.Collections.Generic;
using UnityEditor.SceneManagement;

[CustomEditor(typeof(CameraController))]
public class CameraControllerEditor : Editor
{
    CameraController script { get { return target as CameraController; } }
    AnimationClip clip = null;
    float rotation = 0;
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (script.target_ != null)
        {
            rotation = EditorGUILayout.FloatField("rotation", rotation);
            script.target_.localEulerAngles = new Vector3(0, rotation, 0);
            var animation = script.target_.GetComponentInChildren<Animation>();
            if (animation != null)
            {
                foreach (var state in animation)
                {
                    if (clip == animation.GetClip((state as AnimationState).name)) GUI.contentColor = Color.green;
                    if (GUILayout.Button((state as AnimationState).name, EditorStyles.miniButton))
                    {
                        clip = animation.GetClip((state as AnimationState).name);
                        animation.Play((state as AnimationState).name);
                    }
                    GUI.contentColor = Color.white;
                }
            }

        }
        
    }
}