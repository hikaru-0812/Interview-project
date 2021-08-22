/*
 *FileName:      RootMotionControl.cs
 *Author:        天璇
 *Date:          2020/12/15 00:09:39
 *UnityVersion:  2019.4.0f1
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RootMotionControl : MonoBehaviour
{
    private Animator animator;

    private void Awake()
    {
        animator = GetComponent<Animator>();
    }

    private void OnAnimatorMove()
    {
        SendMessageUpwards("OnUpdateRootMotion", animator.deltaPosition);
    }
}
