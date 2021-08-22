/*
 * FileName:      WeaponData.cs
 * Author:        天璇
 * Date:          2020/12/30 21:21:34
 * UnityVersion:  2019.4.0f1
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponData : MonoBehaviour
{
    [SerializeField]private int atk;
    public int ATK { 
        get => atk;
        set
        {
            if (value >= 0)
                atk = value;
        }
    }

    [SerializeField]private int def;
    public int DEF
    {
        get => def;
        set
        {
            if (value >= 0)
                def = value;
        }
    }
}
