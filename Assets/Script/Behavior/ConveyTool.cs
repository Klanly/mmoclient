/********************************************************************************
** auth： zhangzeng
** date： 2016/12/20
** desc： 传送阵
*********************************************************************************/

using UnityEngine;
using LuaInterface;

public class ConveyTool : EntityBehavior
{
    public string triggerFunc = "OnConvey";
    public LuaTable luaTable { get; set; }

    void OnTriggerEnter(Collider other)
    {
        Transform transform = other.gameObject.transform;
        var behavior = transform.GetComponent<HeroBehavior>();
        if (behavior == null)
        {
            Transform parant = transform.parent;
            if (parant)
            {
                behavior = parant.GetComponent<HeroBehavior>();
                if (behavior == null)
                {
                    return;
                }
            }
        }

        if (luaTable != null)
        {
            var func = luaTable.GetLuaFunction(triggerFunc);
            func.Call(luaTable);
        }
    }
}