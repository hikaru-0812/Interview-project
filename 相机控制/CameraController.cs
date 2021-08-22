using System.Collections;
using System.Collections.Generic;
using _Scripts.角色控制;
using UnityEngine;
using UnityEngine.UI;

public class CameraController : MonoBehaviour
{
    /// <summary>
    /// 锁定的目标
    /// </summary>
    //public class LockTarget
    //{
    //    public GameObject m_obj;
    //    public float m_halfHeight;
    //    public ActorManager m_ac;

    //    /// <summary>
    //    /// 
    //    /// </summary>
    //    /// <param name="_obj">锁定的GameObject</param>
    //    /// <param name="_halfHeight">GameObject的半高</param>
    //    public LockTarget(GameObject _obj, float _halfHeight)
    //    {
    //        m_obj = _obj;
    //        m_halfHeight = _halfHeight;
    //        m_ac = _obj.GetComponent<ActorManager>();
    //    }
    //}

    UserInput inputSystem;
    [SerializeField] private bool mouseLock = false;

    private Transform playerHandle;
    private Transform cameraHandle;
    public float horizontalVelocity = 100.0f;
    public float verticalVelocity = 100.0f;
    private float tempEulerX;
    public GameObject model;
    private new GameObject camera;

    /// <summary>
    /// 记录模型旋转前的角度
    /// </summary>
    public Vector3 tempModleEuler = Vector3.zero;

    private Vector3 cameraDampVelocity;
    public float cameraSmoothTime = 0.5f;

    [Header("相机缩放相关")]
    /// <summary>
    /// 一条相机指向玩家的向量
    /// </summary>
    public Vector3 offset = Vector3.zero;

    /// <summary>
    /// 相机拉伸比例
    /// </summary>
    float scaleDistance = 3.0f;

    /// <summary>
    /// 相机最大缩放距离
    /// </summary>
    public float maxDistance = 2f;

    /// <summary>
    /// 相机最小缩放距离
    /// </summary>
    public float minDistance = 0.5f;

    /// <summary>
    /// 锁定的攻击目标
    /// </summary>
    //public LockTarget lockTatget;

    /// <summary>
    /// 锁定标识
    /// </summary>
    private Image lockDot;

    public bool isAI = false;

    private void Awake()
    {
        cameraHandle = transform.parent;
        playerHandle = cameraHandle.parent;
        lockDot = GameObject.Find("Lock Image").GetComponent<Image>();

        if (false == isAI)
        {
            camera = Camera.main.gameObject;
            lockDot.enabled = false;

            //鼠标锁定到屏幕中央
            if (true == mouseLock)
                Cursor.lockState = CursorLockMode.Locked;
        }

        //modle = transform.GetChild(3).gameObject;
        offset = cameraHandle.transform.position - transform.position;
        
    }

    private void Start()
    {
        inputSystem = transform.parent.parent.GetComponent<ActorController>().InputSystem;
    }

    private void Update()
    {
        if (Time.timeScale != 0)//游戏不暂停时
        {
            //左Alt键解锁鼠标
            if (Input.GetKey(KeyCode.LeftAlt))
            {
                Cursor.lockState = CursorLockMode.Confined;
                inputSystem.InputEnable = false;
            }
            else
            {
                Cursor.lockState = CursorLockMode.Locked;
                inputSystem.InputEnable = true;
            }
        }

        //锁定点UI在敌人身高的一半
        //if (null != lockTatget)
        //{
        //    if(false == isAI)
        //        lockDot.rectTransform.position = Camera.main.WorldToScreenPoint(lockTatget.m_obj.transform.position + new Vector3(0, lockTatget.m_halfHeight, 0));
        //    //距离过远或敌人死亡就取消锁定
        //    if (Vector3.Distance(modle.transform.position, lockTatget.m_obj.transform.position) > 10.0f || lockTatget.m_ac.stateManager.isDie)
        //        UnLock();
        //}
    }

    private void FixedUpdate()
    {
        //if (null == lockTatget)
        {
            tempModleEuler = model.transform.eulerAngles;

            //相机左右转动
            playerHandle.Rotate(Vector3.up, inputSystem.CameraRotation.x * horizontalVelocity * Time.fixedDeltaTime);

            // 相机上下转动
            tempEulerX += inputSystem.CameraRotation.z * -verticalVelocity * Time.fixedDeltaTime;
            tempEulerX = Mathf.Clamp(tempEulerX, -10f, 89f);
            cameraHandle.localEulerAngles = new Vector3(tempEulerX, 0, 0);

            //人物模型复位
            model.transform.eulerAngles = tempModleEuler;
        }
        //else
        //{
        //    Vector3 tempForward = lockTatget.m_obj.transform.position - modle.transform.position;
        //    tempForward.y = 0;
        //    //相机锁定敌人
        //    playerHandle.transform.forward = tempForward;
        //    //相机看敌人脚底
        //    cameraHandle.transform.LookAt(lockTatget.m_obj.transform);
        //}

        if (false == isAI)
        {
            //相机缩放
            offset = cameraHandle.transform.position - transform.position;

            float tempScale = Input.GetAxis("Mouse ScrollWheel");
            scaleDistance -= tempScale;

            if (scaleDistance >= maxDistance)
                scaleDistance = maxDistance;
            if (scaleDistance <= minDistance)
                scaleDistance = minDistance;

            offset = offset.normalized * 2.0f * scaleDistance;
            transform.position = cameraHandle.transform.position - offset;

            //相机平滑移动
            cameraDampVelocity *= Time.fixedDeltaTime;
            camera.transform.position = Vector3.SmoothDamp(camera.transform.position, transform.position, ref cameraDampVelocity, cameraSmoothTime);
            camera.transform.eulerAngles = transform.eulerAngles;
        }
    }

    /// <summary>
    /// 锁定敌人
    /// </summary>
    public void Lock()
    {
        #region 废案
        //Vector3 modelOrigin1 = modle.transform.position;
        //Vector3 modelOrigin2 = modelOrigin1 + Vector3.up;
        //Vector3 boxCenter = modelOrigin2 + modle.transform.forward * 5.0f;
        //Collider[] cols = Physics.OverlapBox(boxCenter, new Vector3(0.5f, 0.5f, 0.5f), modle.transform.rotation, LayerMask.GetMask(isAI ? TagAndLayer.LayerPlayer : TagAndLayer.LayerEnemy));

        //foreach (var col in cols)
        //{
        //    print(col.gameObject.name);
        //}

        //if (cols.Length == 0)
        //{
        //    UnLock();
        //}
        //else
        //{
        //    foreach (var col in cols)
        //    {
        //        //print(col.gameObject.name);
        //        if (null != lockTatget && lockTatget.m_obj == col.gameObject)
        //        {
        //            UnLock();
        //            break;
        //        }

        //        //print(col.gameObject.name);
        //        //(Collider.bounds.extents)https://docs.unity.cn/cn/current/ScriptReference/Bounds.html
        //        lockTatget = new LockTarget(col.gameObject, col.bounds.extents.y);
        //        lockDot.enabled = true;
        //        break;
        //    }
        //    //if (Vector3.Distance(modle.transform.position, lockTatget.m_obj.transform.position) > 10.0f)
        //}
        #endregion


        
    }

    public void UnLock()
    {
        //lockTatget = null;
        if(false == isAI)
            lockDot.enabled = false;
    }
}
