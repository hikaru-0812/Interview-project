/*
 *FileName:      AnimTriggerReset.cs
 *Author:        天璇
 *Date:          2020/12/13 15:35:16
 *UnityVersion:  2019.4.0f1
 */
using UnityEngine;

/// <summary>
/// 用于清除动画事件中attack trigger
/// </summary>
public class AnimTriggerReset : MonoBehaviour
{
    Animator anim;

    private void Awake()
    {
        anim = GetComponent<Animator>();
    }

    public void ResetTrigger(string _triggerName)
    {
        anim.ResetTrigger(_triggerName);
    }
}
