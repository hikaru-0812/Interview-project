/*
 *FileName:      WeaponManager.cs
 *Author:        天璇
 *Date:          2020/12/22 22:11:44
 *UnityVersion:  2019.4.0f1
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponManager : IActorManager
{
    //public ActorManager actorManager;

    public Collider weaponCollider;
    public Transform weaponHandle;
    public GameObject weapon;
    public GameObject shield;
    public WeaponController weaponController;

    public MyTimer timer;

    private void Awake()
    {
        weaponHandle = transform.DeepFind("WeaponHandle");
        shield = transform.DeepFind("Shield").gameObject;
        weaponController = BindWeaponController(weaponHandle);
        weaponCollider = weaponHandle.GetComponentInChildren<CapsuleCollider>();
        timer = gameObject.AddComponent<MyTimer>();
    }

    public void UpdataWeaponCollider(Collider _targetCollider)
    {
        weaponCollider = _targetCollider;
    }

    public void UnloadWeapon()
    {
        foreach (Transform item in weaponHandle.transform)
        {
            weaponCollider = null;
            weaponController.weaponData = null;
            Destroy(item.gameObject);
        }
    }

    public WeaponController BindWeaponController(Transform _obj)
    {
        WeaponController tempWeaponController = _obj.GetComponent<WeaponController>();
        
        if (null == tempWeaponController)
            tempWeaponController = _obj.gameObject.AddComponent<WeaponController>();

        tempWeaponController.weaponManager = this;

        return tempWeaponController;
    }

    public void WeaponColliderEnable()
    {
        weaponCollider.enabled = true;
    }

    public void WeaponColliderDisable()
    {
        weaponCollider.enabled = false;
    }

    public void WeaponEnable()
    {
        weapon.SetActive(true);
    }

    public void WeaponDisable()
    {
        weapon.SetActive(false);
    }

    public void WeaponDisableStart()
    {
        //if (actorManager.actorController.animator.GetFloat(HashIDs.speedFloat) > 0.1f)
        {
            timer.StartTickTock(5.0f);
        }
    }

    public void WeaponDisableUpdate()
    {
        if (timer.TimeUp)
            actorManager.actorController.SetTrigger(HashIDs.SheathWeaponTrigger);
    }

    public void ShieldEnable()
    {
        shield.SetActive(true);
    }

    public void ShieldDisable()
    {
        shield.SetActive(false);
    }

    public void CountBackEnable()
    {
        actorManager.SetIsCountBack(true);
    }

    public void CountBackDisable()
    {
        actorManager.SetIsCountBack(false);
    }
}
