/*
 * FileName:      WeaponFactory.cs
 * Author:        天璇
 * Date:          2021/01/01 17:52:38
 * UnityVersion:  2019.4.0f1
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using EquipmentData;

public class WeaponFactory
{
    private DataBase dataBase;

    public WeaponFactory(DataBase dataBase)
    {
        this.dataBase = dataBase;
    }

    /// <summary>
    /// 创造怪物掉落的武器
    /// </summary>
    /// <param name="_weaponName"></param>
    /// <param name="_position"></param>
    /// <param name="_quaternion"></param>
    /// <returns></returns>
    public GameObject CreateDropWeapon(string _weaponName, Vector3 _position, Quaternion _quaternion)
    {
        //用预制体创建GameObject
        GameObject weaponPrefab = Resources.Load(_weaponName) as GameObject;
        GameObject tempObj = GameObject.Instantiate(weaponPrefab, _position, _quaternion);

        //装配数值
        WeaponData weaponData = tempObj.AddComponent<WeaponData>();
        dataBase = new DataBase(_weaponName);
        weaponData.ATK = dataBase.ATK;
        weaponData.DEF = dataBase.DEF;

        return tempObj;
    }

    /// <summary>
    /// 创造角色使用的武器
    /// </summary>
    /// <param name="_weaponName"></param>
    /// <param name="_playerWeaponManager"></param>
    /// <returns></returns>
    public GameObject CreatePlayerWeapon(string _weaponName, WeaponManager _playerWeaponManager)
    {
        //用预制体创建GameObject
        GameObject weaponPrefab = Resources.Load(_weaponName) as GameObject;
        GameObject tempObj = GameObject.Instantiate(weaponPrefab);
        tempObj.transform.SetParent(_playerWeaponManager.weaponController.transform);//放在手心
        tempObj.transform.localPosition = new Vector3(-0.0288f, -0.016f, 0.0083f);
        tempObj.transform.localEulerAngles = Vector3.zero;
        tempObj.tag = TagAndLayer.TagWeapon;

        //装配数值
        WeaponData tempWeaponData = tempObj.AddComponent<WeaponData>();//挂载WeaponData
        dataBase = new DataBase(_weaponName);
        tempWeaponData.ATK = dataBase.ATK;
        tempWeaponData.DEF = dataBase.DEF;
        _playerWeaponManager.weaponController.weaponData = tempWeaponData;

        return tempObj;
    }   

    /// <summary>
    /// 创造敌人的武器
    /// </summary>
    /// <param name="_enemyName"></param>
    /// <param name="_tempObj"></param>
    /// <param name="_enemyWeaponManager"></param>
    /// <returns></returns>
    public GameObject CreateEnemyWeapon(string _enemyName, GameObject _tempObj, WeaponManager _enemyWeaponManager)
    {
        //敌人身上已有VisualWeapon，装配数值即可
        WeaponData tempWeaponData = _tempObj.AddComponent<WeaponData>();//挂载WeaponData
        dataBase = new DataBase(_enemyName);
        tempWeaponData.ATK = dataBase.ATK;
        tempWeaponData.DEF = dataBase.DEF;
        _enemyWeaponManager.weaponController.weaponData = tempWeaponData;

        return _tempObj;
    }
}
