/*
 *FileName:      WeaponController.cs
 *Author:        天璇
 *Date:          2020/12/24 21:23:43
 *UnityVersion:  2019.4.0f1
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponController : MonoBehaviour
{
    public WeaponManager weaponManager;
    public WeaponData weaponData;

    private void Awake()
    {
        weaponData = GetComponentInChildren<WeaponData>();
    }

    public int GetATK()
    {
        return weaponData.ATK + weaponManager.actorManager.stateManager.ATK - weaponData.DEF;
    }
}
