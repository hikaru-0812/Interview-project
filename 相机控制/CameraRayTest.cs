/*
 *FileName:      CameraRayTest.cs
 *Author:        天璇
 *Date:          2020/12/19 00:55:28
 *UnityVersion:  2019.4.0f1
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraRayTest : MonoBehaviour
{
    private Transform cameraHandle;
    private Camera mainCamera;

    public struct Points
    {
        public Vector3 LowerRight;
        public Vector3 LowerLeft;
    }
    private Points planePoints;

    void Awake()
    {
        cameraHandle = transform.parent;
        mainCamera = Camera.main;
    }

    void Update()
    {
        
    }

    public void NearClipPlanePoints()
    {
        var pos = cameraHandle.position;
        var transform = mainCamera.transform;
        var halfFOV = (mainCamera.fieldOfView / 2) * Mathf.Deg2Rad;
        var aspect = mainCamera.aspect;
        var distance = mainCamera.nearClipPlane;
        var height = distance * Mathf.Tan(halfFOV);
        var width = height * aspect;
        height *= 2f;
        width *= 2f;
        planePoints.LowerRight = pos + transform.right * width;
        planePoints.LowerRight -= transform.up * height;
        planePoints.LowerRight += transform.forward * distance;
    }

    //void PhysicalProcess()
    //{
    //    RaycastHit hitInfo;
    //    Vector3 from = camera_x.position;
    //    var _to = planePoints;
    //    var rayDistance = Vector3.Distance(cameraHandle.position, from) + 0.1f;
    //    float distance = rayDistance;
    //    bool hit = false;

    //    NearClipPlanePoints();
    //    if (Physics.Raycast(from, _to.LowerLeft - from, out hitInfo, rayDistance, coverLayerMask))
    //    {
    //        hit = true;
    //        if (distance > hitInfo.distance) 
    //            distance = hitInfo.distance;
    //    }

    //    if (hit)
    //    {
    //        cameraObj.position = from + (cameraHandle.position - from).normalized * (distance - 0.2f);
    //    }
    //    else
    //        cameraObj.localPosition = Vector3.zero;
    //}
}
