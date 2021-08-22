/*
 *FileName:      BattleManager.cs
 *Author:        天璇
 *Date:          2020/12/22 19:03:23
 *UnityVersion:  2019.4.0f1
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(CapsuleCollider))]
public class BattleManager : IActorManager
{
    /// <summary>
    /// 受击检测触发器
    /// </summary>
    [HideInInspector]
    public CapsuleCollider hitCol;

    private void Start()
    {
        hitCol = GetComponent<CapsuleCollider>();
        hitCol.center = new Vector3(0, 0.68f, 0);
        hitCol.height = 1.4f;
        hitCol.radius = 0.2f;
        hitCol.isTrigger = true;
    }

    private void OnTriggerEnter(Collider other)
    {
        WeaponController enemyWc = other.GetComponentInParent<WeaponController>();

        if(null != enemyWc)
        {
            GameObject attacker = enemyWc.weaponManager.actorManager.actorController.model;
            GameObject receiver = actorManager.actorController.model;
            Vector3 attackerToReceiver = receiver.transform.position - attacker.transform.position;
            Vector3 receiverrToAttacke = attacker.transform.position - receiver.transform.position;

            float attackAngle = Vector3.Angle(attacker.transform.forward, attackerToReceiver);//攻击者的攻击范围

            float counterAngle1 = Vector3.Angle(receiver.transform.forward, receiverrToAttacke);//受击者的盾反范围
            float counterAngle2 = Vector3.Angle(attacker.transform.forward, receiver.transform.forward);//攻击者的forward与受击者的forward的角度

            //攻击者的攻击范围为相对于攻击者的forward向左45度向右45度，共90度
            //故由攻击者forward和攻击者指向受击者的向量的夹角来决定是否在攻击范围内
            bool attackValid = attackAngle < 45;

            //受击者的盾反范围相对于受击者的forward向左45度向右45度，共90度
            //故由受击者forward和受击者指向攻击者的向量的夹角来决定是否在盾反范围内
            //攻击者的forward与受击者的forward的角度，应该尽量接近180度，才能说明现在的情况是面对面
            bool counterValid = counterAngle1 < 90 && ((counterAngle2 < 0 ? -counterAngle2 : counterAngle2 - 180f/*取绝对值*/) < 90);

            if (other.CompareTag(TagAndLayer.TagWeapon) && enemyWc.weaponManager.actorManager.stateManager.isAttacked == false)
            {
                actorManager.TryDoDamage(enemyWc, attackValid, counterValid);
            }
        }
    }
}
