/*
 *FileName:      StateManager.cs
 *Author:        天璇
 *Date:          2020/12/23 10:32:39
 *UnityVersion:  2019.4.0f1
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StateManager : IActorManager
{
    private Animator animator;

    [Header("1阶旗标")]
    public bool isGround;
    public bool isJump;
    public bool isFall;
    public bool isAttack;
    public bool isHit;
    public bool isDie;
    public bool isBlocked;
    public bool isdodge;
    public bool isInteractive;

    /// <summary>
    /// 状态弹反
    /// </summary>
    public bool isCounterBack;
    /// <summary>
    /// 动画事件弹反
    /// </summary>
    public bool isCounterBackEnable;

    [Header("2阶旗标")]
    public bool isDefense;

    /// <summary>
    /// 是否允许防御
    /// </summary>
    public bool isAllowDefense;

    /// <summary>
    /// 是否为无敌状态
    /// </summary>
    public bool isImmortal;

    /// <summary>
    /// 是否盾反成功
    /// </summary>
    public bool isCounterBackSuccess;

    /// <summary>
    /// 是否盾反失败
    /// </summary>
    public bool isCounterBackFailure;

    /// <summary>
    /// 在一次攻击动画过程中是否已经受到伤害
    /// </summary>
    [HideInInspector]
    public bool isAttacked;

    [Header("人物属性")]
    public float maxHP;
    [SerializeField]private float hp;
    public float HP
    {
        get { return hp; }
        set {
            if (value >= 0)
                hp = value;
            else
                hp = 0;
        }
    }

    private int atk;
    public int ATK
    {
        get => atk;
        set{
            if (value >= 0)
                atk = value;
            else
                return;
        }
    }

    //HP相关的委托和事件
    public delegate void GetHP(float _value);
    public event GetHP HPEvent;

    private void Awake()
    {
        //根据角色名字修正初始血量（暂定）
        if (transform.name == "PlayerHandle")
        {
            maxHP = 200;
            hp = 100;
        }
        if (transform.name == "Enemy1")
        {
            maxHP = 100;
            hp = 100;
        }
        if (transform.name == "Enemy2")
        {
            maxHP = 1000;
            hp = 1000;
        }

        animator = GetComponentInChildren<Animator>();

        HPEvent?.Invoke(hp);//广播HP事件
    }

    private void Update()
    {
        //更新状态
        isGround = actorManager.actorController.isGround;
        isJump = animator.CheckState(HashIDs.jump) || animator.CheckState(HashIDs.jumpF);
        isFall = animator.CheckState(HashIDs.fall);
        isAttack = animator.CheckStateTag(HashIDs.attackTag);
        isHit = animator.CheckState(HashIDs.hit);
        isDie = animator.CheckState(HashIDs.die);
        isBlocked = animator.CheckState(HashIDs.blocked);
        isdodge = animator.CheckStateTag(HashIDs.dodgeTag);
        isCounterBack = animator.CheckState(HashIDs.counterBack);
        isInteractive = actorManager.actorController.InputSystem.IsInteractive;

        isAllowDefense = isGround || isBlocked;
        isDefense = isAllowDefense && animator.CheckState(HashIDs.defense);
        isImmortal = isdodge || isDefense || isBlocked;
        isCounterBackSuccess = isCounterBackEnable;
        isCounterBackFailure = isCounterBack && !isCounterBackEnable;//限定弹反帧

        HPEvent(hp);
    }

    public void AddHP(int _value)
    {
        HP += _value;
        HP = Mathf.Clamp(HP, 0, maxHP);

        //if (HP > 0)
        //    actorManager.Hit();
        //else
        //    actorManager.Die();
    }
}
