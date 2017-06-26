using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;

[ExecuteInEditMode]
[RequireComponent(typeof(Toggle))]
public class UIToggle : MonoBehaviour
{
    public List<GameObject> activeObject = new List<GameObject>();
    public List<GameObject> deactiveObject = new List<GameObject>();
    void Awake()
    {
        var toggle = GetComponent<Toggle>();
        toggle.onValueChanged.AddListener(OnValueChange);
        OnValueChange(toggle.isOn);
    }

    void OnValueChange(bool value)
    {
        for (int i = 0; i < activeObject.Count; i++)
        {
            activeObject[i].SetActive(value);
        }
        for (int i = 0; i < deactiveObject.Count; i++)
        {
            deactiveObject[i].SetActive(!value);
        }
    }

}
