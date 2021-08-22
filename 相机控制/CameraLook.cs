using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraLook : MonoBehaviour
{
    public float moveSpeed = 5.0f;
    public bool mouseLock = false;
    
    /// <summary>
    /// 记录玩家位置
    /// </summary>
    Transform Player;

    /// <summary>
    /// 平滑过渡时间
    /// </summary>
    public float smoothTime = 0.0f;

    /// <summary>
    /// 一条相机指向玩家的向量
    /// </summary>
    public Vector3 offset = Vector3.zero;

    /// <summary>
    /// 相机拉伸比例
    /// </summary>
    float scaleDistance = 3.0f;

    /// <summary>
    /// 抬头低头角度
    /// </summary>
    float currentAngle = 0.0f;

    /// <summary>
    /// 射线检测信息
    /// </summary>
    RaycastHit hitInfo;

    /// <summary>
    /// 一条射线
    /// </summary>
    Ray ray;

    /// <summary>
    /// 
    /// </summary>
    //float roateSpeed = 6.0f;

    void Start()
    {
        //鼠标锁定到屏幕中央
        if (true == mouseLock)
            Cursor.lockState = CursorLockMode.Locked;

        Player = GameObject.FindGameObjectWithTag("Player").transform;
        offset = transform.position - Player.position;
        ray = new Ray(Player.position, -offset);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#else
            Application.Quit();
#endif
    }

    void LateUpdate()
    {
        #region
        ////moveDirection = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical")).normalized;
        ////targetRotate = Quaternion.FromToRotation(transform.forward, moveDirection) * transform.rotation;

        ////相机跟随
        //CameraPosition = Player.position + offset;
        ////transform.position = Vector3.Lerp(transform.position, CameraPosition, smoothTime * Time.deltaTime);
        //transform.position = CameraPosition;

        ////相机旋转
        //#region 失败方案
        ////绕自身y轴
        //transform.Rotate(Vector3.up, Input.GetAxis("Mouse X"));

        ////绕自身y轴（世界）
        //transform.Rotate(Vector3.up, Input.GetAxis("Mouse X"), Space.World);

        ////绕玩家的y轴（世界）旋转
        //transform.Rotate(Player.transform.position, Input.GetAxis("Mouse X"), Space.World);
        //#endregion
        ////绕玩家的y轴（世界）旋转
        //transform.RotateAround(Player.transform.position, Vector3.up, Input.GetAxis("Mouse X"));
        //offset = transform.position - Player.position;
        ////transform.Rotate(Vector3.right , -Mathf.Clamp(Input.GetAxis("Mouse Y"), -0.1f, 0.1f) * horizontalSpeed);
        ////Debug.Log(Mathf.Clamp(Input.GetAxis("Mouse Y"), -0.1f, 0.1f));

        ////transform.rotation = Quaternion.Slerp(transform.rotation, targetRotate, roateSpeed);
        ////transform.position += moveDirection * moveSpeed * Time.deltaTime;

        ////transform.position = new Vector3(transform.position.x, height, transform.position.z);
        #endregion

        transform.position = Player.position + offset;

        //左看右看
        transform.RotateAround(Player.transform.position, Vector3.up, 2f * Input.GetAxis("Mouse X"));

        //抬头低头
        float tempUpDownAngle = Input.GetAxis("Mouse Y");
        currentAngle += tempUpDownAngle;

        if (currentAngle >= 30.0f)
        {
            currentAngle = 30.0f;
            tempUpDownAngle = 0.0f;
        }

        if (currentAngle <= -89.0f)
        {
            currentAngle = -89.0f;
            tempUpDownAngle = 0.0f;
        }

        transform.RotateAround(Player.transform.position, new Vector3(-offset.z, 0, offset.x), -tempUpDownAngle);
        transform.eulerAngles = new Vector3(transform.eulerAngles.x, transform.eulerAngles.y, 0);

        offset = transform.position - Player.position;

        //相机缩放
        float tempScale = Input.GetAxis("Mouse ScrollWheel");
        scaleDistance -= tempScale;

        if (scaleDistance >= 2)
            scaleDistance = 2.0f;
        if (scaleDistance <= 0.5)
            scaleDistance = 0.5f;

        offset = offset.normalized * 2.0f * scaleDistance;

    //    //处理相机穿墙问题
    //    ray = Camera.main.ScreenPointToRay(Input.mousePosition);

    //    if (Physics.Raycast(ray, out hitInfo, LayerMask.GetMask("Player")))
    //    {
    //        if (!hitInfo.collider.CompareTag("MainCamera"))
    //        {
    //            //transform.position = Vector3.Lerp(transform.position, Player.position, smoothTime * Time.deltaTime);
    //            if (Vector3.Distance(transform.position, hitInfo.point) < Vector3.Distance(transform.position, Player.transform.position))
    //            {
    //                //transform.position = Player.position;
    //                transform.position = hitInfo.point;//偏移
    //            }
    //        }
    //    }
    }
}