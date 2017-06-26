using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;

public class MapOperate : MonoBehaviour
{
    private bool bInTouch = false;
    private Vector3 mousePosOld = Vector3.zero;
    private Vector3 mousePosLast = Vector3.zero;
    private GameObject goCamera = null;
    private Camera mCamera = null;
    private Vector3 vCamPosOld = Vector3.zero;
    private bool Dragged = false;
    private float ClickAfter = 0.0f;
    private MapResProperty MouseClickedCharacter = null;
    private float zoomCurrent = 5.23f;

    private float zoomMax = 12;
    private float zoomMin = 4;
    private float zoomSpeed = 4;
    private float speed = 250.0f;
    private bool bIsScale = false;
    void Start()
    {
        goCamera = GameObject.FindGameObjectWithTag("MainCamera");
        mCamera = goCamera.GetComponent<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        if (EventSystem.current.IsPointerOverGameObject())
        {
           // DelSelectedGo();
            return;
        }
        if (Input.GetMouseButton(0))
        {
            if (!bInTouch)
            {
                bInTouch = true;
                DelSelectedGo();
                Dragged = false;
                mousePosOld = Input.mousePosition;
                mousePosLast = Input.mousePosition;
                vCamPosOld = goCamera.transform.position;
                LayerMask mask = 1 << LayerMask.NameToLayer("Pet") | 1 << LayerMask.NameToLayer("Npc") | 1 << LayerMask.NameToLayer("Monster") | 1 << LayerMask.NameToLayer("Trigger") | 1 << LayerMask.NameToLayer("Wall");
                Ray ray = Camera.main.ScreenPointToRay(mousePosOld);
                RaycastHit hit;
                if (Physics.Raycast(ray, out hit, 600, mask.value))
                {
                    DelSelectedGo();
                    MouseClickedCharacter = hit.collider.gameObject.GetComponent<MapResProperty>();
                    if (MouseClickedCharacter.transform.FindChild("SelectedReg")) return;
                    GameObject goResSign = null;
#if UNITY_EDITOR
                    goResSign = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>("Assets/PublishRes/DesignTools/SelectedReg"+".prefab");
#endif
                    GameObject gosel = (GameObject)Instantiate(goResSign,Vector3.zero, Quaternion.identity);
                    gosel.name = "SelectedReg";
                    gosel.transform.SetParent(MouseClickedCharacter.transform);
                    gosel.transform.localPosition = Vector3.zero;
                    gosel.transform.localEulerAngles = Vector3.zero;
                    if(MouseClickedCharacter.GetResType() == 18)
                    {
                        if(gosel.transform.lossyScale!= 0.5f*Vector3.one)
                        {
                            Vector3 vec = gosel.transform.localScale;
                            float x = 0.5f / gosel.transform.lossyScale.x;
                            float z =  0.5f/ gosel.transform.lossyScale.z;
                            gosel.transform.localScale = new Vector3(vec.x * x, vec.y, vec.z*z);

                        }
                    }
                    MapDesignTools.instance.SelectedGO = MouseClickedCharacter.gameObject;
                   

                }
                else
                {
                    MouseClickedCharacter = null;
                    MapDesignTools.instance.SelectedGO = null;
                    MapDesignTools.instance.HideUnitProp();
                }
            }
            else
            {
                if (Vector3.Distance(Input.mousePosition, mousePosLast) > 0.01f)
                {
                    if (!Dragged)
                    {
                        Dragged = true;
                        MapDesignTools.instance.HideUnitProp();
                    }
                    mousePosLast = Input.mousePosition;
                    if (MouseClickedCharacter != null)
                    {
                        Vector3 pos = MapDataProccess.instance.GetTerrainPos(Input.mousePosition, true);
                        pos.y += 0.01f;
                        int kResType = MouseClickedCharacter.GetResType();
                        if (kResType == 16)
                            pos.y += 0.8f;
                        MouseClickedCharacter.transform.position = pos;
                    }
                    else
                    {
                        Vector3 vDelta = (Input.mousePosition - mousePosOld) * 0.06f;
                        Vector3 vForward = goCamera.transform.forward; vForward.y = 0.0f; vForward.Normalize();
                        Vector3 vRight = goCamera.transform.right; vRight.y = 0.0f; vRight.Normalize();
                        Vector3 vMove = -vForward * vDelta.y + -vRight * vDelta.x;
                        goCamera.transform.position = vCamPosOld + vMove;
                    }
                }
                else
                {
                    if (!Dragged)
                    {
                        ClickAfter += Time.deltaTime;
                        if ((ClickAfter > 0.5f))
                        {
                          //  Pick();
                        }
                    }
                }
            }

        }
        else  //释放鼠标
        {
            if (bInTouch)
            {
                bInTouch = false;
                if (MouseClickedCharacter != null& Dragged)
                {
                    Transform tf = MouseClickedCharacter.transform.FindChild("SelectedReg");
                    DestroyImmediate(tf.gameObject);
                    MouseClickedCharacter = null;
                    MapDesignTools.instance.SelectedGO = null;                    
                }
                else if(MouseClickedCharacter != null)
                {
                    if (MouseClickedCharacter.GetResType() == 16)
                    {
                        MapDesignTools.instance.ShowUnitProp();
                    }
                    else
                    {
                        MapDesignTools.instance.HideUnitProp();
                    }
                }
            }
        }
        
        if(MapDesignTools.instance.SelectedGO)
        {
            if (Input.GetKey(KeyCode.Delete))
            {
                GameObject go = MapDesignTools.instance.SelectedGO;
                
                MapDesignTools.instance.SelectedGO = null;
                int eid = go.GetComponent<MapResProperty>().GetEid();
                MapDataProccess.instance.ResList.Remove(eid);

                int typeId = go.GetComponent<MapResProperty>().GetResType();
                if (typeId == 16) MapDesignTools.instance.HideUnitProp();
                DestroyImmediate(go);

            }

           

            if (Input.GetAxis("Mouse ScrollWheel") < 0)
            {
                MapDesignTools.instance.SelectedGO.transform.Rotate(Vector3.up * Time.deltaTime * speed);

            }
         
            if (Input.GetAxis("Mouse ScrollWheel") > 0)
            {
                MapDesignTools.instance.SelectedGO.transform.Rotate(-Vector3.up * Time.deltaTime * speed);
            }

            if (Input.GetKeyDown(KeyCode.Space) )
            {
                Vector3 pos = MapDesignTools.instance.SelectedGO.transform.position + new Vector3(0.8f, 0, 0);
                MouseClickedCharacter = MapDesignTools.instance.SelectedGO.GetComponent<MapResProperty>();
                GameObject NewGO = (GameObject)Instantiate(MapDesignTools.instance.SelectedGO, pos, Quaternion.identity);
                DelSelectedGo();
                MapResProperty newResProp =  NewGO.GetComponent<MapResProperty>();
                if(newResProp == null)
                {
                    newResProp = NewGO.AddComponent<MapResProperty>();
                }
                int eId = MapDataProccess.instance.GetLastID();
                NewGO.name = NewGO.name.Replace("(Clone)", "").Replace(MouseClickedCharacter.GetEid().ToString(),"") + eId.ToString();
                newResProp.SetResType(MouseClickedCharacter.GetResType());
                newResProp.SetEid(eId);
                newResProp.SetName(MouseClickedCharacter.GetName());
                newResProp.SetResPath(MouseClickedCharacter.GetResPath());
                MapDesignTools.instance.SelectedGO = NewGO;
                NewGO.transform.SetParent(MapDesignTools.instance.ResRoot.transform);
                MapDataProccess.instance.ResList.Add(eId, newResProp);
            }

        }
        else
        {
            if (Input.GetAxis("Mouse ScrollWheel") < 0)
            {

                Vector3 back = -mCamera.transform.right;
                mCamera.transform.Translate(back * Time.deltaTime * speed);

            }
            //Zoom in
            if (Input.GetAxis("Mouse ScrollWheel") > 0)
            {
                Vector3 forward = mCamera.transform.right;
                mCamera.transform.Translate(forward * Time.deltaTime * speed);
            }
        }

        if(Input.GetKeyDown(KeyCode.F1))
        {
            MapDesignTools.instance.HideShowHelp();
        }
        
    }

    public void DelSelectedGo()
    {
        if (MapDesignTools.instance.SelectedGO)
        {
            Transform tf = MapDesignTools.instance.SelectedGO.transform.FindChild("SelectedReg");
            DestroyImmediate(tf.gameObject);
            MapDesignTools.instance.SelectedGO = null;
        }

    }

    void OnGUI()
    {
        if(MapDesignTools.instance.SelectedGO)
        {
            bIsScale = false;
            MapResProperty resProp = MapDesignTools.instance.SelectedGO.GetComponent<MapResProperty>();
            Transform Seledtf = MapDesignTools.instance.SelectedGO.transform.FindChild("SelectedReg");
            Vector3 selScale = Seledtf.localScale;
            float facx = 1f;
            float facy = 1f;
            float facz = 1f;
            float scaleFactorx = 0f;
            float scaleFactory = 0f;
            float scaleFactorz = 0f;
            if (resProp.GetResType() != 16&& resProp.GetResType() != 18) return;
            Vector3 localScale = MapDesignTools.instance.SelectedGO.transform.localScale;
            Vector3 scale = Vector3.one;
            if (Input.GetKey(KeyCode.LeftArrow))
            {
                if(resProp.GetResType() == 16)
                   scaleFactorx = -0.1f;
                else
                    scaleFactorz = -0.1f;
                bIsScale = true;
            }
            if (Input.GetKey(KeyCode.RightArrow))
            {
                if (resProp.GetResType() == 16)
                    scaleFactorx = 0.1f;
                else
                    scaleFactorz = 0.1f;
                bIsScale = true;
            }
            if (Input.GetKey(KeyCode.UpArrow))
            {
                if (resProp.GetResType() == 16)
                    scaleFactorz = 0.1f;
                else
                    scaleFactory = 0.1f;
                bIsScale = true;
            }
            if (Input.GetKey(KeyCode.DownArrow))
            {
                if (resProp.GetResType() == 16)
                    scaleFactorz = -0.1f;
                else
                    scaleFactory = -0.1f;
                bIsScale = true;
            }
           
            if(bIsScale)
            {
                scale = new Vector3(localScale.x + scaleFactorx, localScale.y + scaleFactory, localScale.z + scaleFactorz);
                facx = scale.x / localScale.x;
                facy = scale.y / localScale.y;
                facz = scale.z / localScale.z;
                if (resProp.GetResType() == 16 && (scale.x <= 3f || scale.z <= 3f))
                {
                    UIDialogMessage.Show("已经缩放到最小了.......");
                    return;
                }
                
                MapDesignTools.instance.SelectedGO.transform.localScale = scale;
                Vector3 Selectedscale = new Vector3(selScale.x / facx, selScale.y / facy, selScale.z / facz);
                Seledtf.localScale = Selectedscale;  //选中面片不缩放
            }

        }
       
    }



  }
