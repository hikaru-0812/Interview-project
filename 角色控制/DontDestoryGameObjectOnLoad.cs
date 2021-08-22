/*
 * FileName:      NewBehaviourScript.cs
 * Author:        天璇
 * Date:          2021/01/12 22:11:06
 * UnityVersion:  2019.4.0f1
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DontDestoryGameObjectOnLoad : MonoBehaviour
{
    void OnEnable()
    {
        DontDestroyOnLoad(gameObject);
    }
}
