using UnityEngine;
using System.Collections.Generic;

public class Dress : MonoBehaviour
{
    public string[] dressParts = new string[3];
    [ContextMenu("Reset dressParts")]
    public void Merge()
    {
        DressPart.ChangeClothes(gameObject, dressParts);
    }
}
