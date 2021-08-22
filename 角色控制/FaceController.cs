/*
 *FileName:      FaceController.cs
 *Author:        天璇
 *Date:          2020/12/18 10:24:44
 *UnityVersion:  2019.4.0f1
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FaceController : MonoBehaviour
{
    SkinnedMeshRenderer 表情;
    [Range(0, 100)] public float eyes;

    void Awake()
    {
        表情 = transform.GetChild(1).GetChild(1).GetComponent<SkinnedMeshRenderer>();
    }

    void Update()
    {
        表情.SetBlendShapeWeight(3, eyes);
    }
}
