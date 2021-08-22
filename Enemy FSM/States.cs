using System;
using UnityEngine;
using MyUnityFramework;
using System.Collections.Generic;
using System.Collections;
using _Scripts.Enemy_FSM;

public class IdleState : BaseState, IState
{
    public IdleState(EnemyAI enemybrain) : base(enemybrain) { }

    public void OnEnter()
    {
        parameter.animator.SetFloat("MoveSpeed", 0.0f);
    }

    public void OnExit()
    {
        
    }

    public void OnUpdate()
    {
        if (parameter.animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 1.0f)
            enemybrain.TransitionState(StateType.Walk);
    }
}

public class WalkState : BaseState, IState
{
    public WalkState(EnemyAI enemybrain) : base(enemybrain) { }

    public void OnEnter()
    {
        parameter.animator.SetFloat("MoveSpeed", 0.5f);
        parameter.targetWayPoint = parameter.wayPoint1;
        //parameter.navMeshAgent.isStopped = true;
    }

    public void OnExit()
    {

    }

    public void OnUpdate()
    {
        //在两点之间巡逻
        if (Vector3.Distance(enemybrain.transform.position, parameter.wayPoint2.position) <= 0.3f)
            parameter.targetWayPoint = parameter.wayPoint1;
        if (Vector3.Distance(enemybrain.transform.position, parameter.wayPoint1.position) <= 0.3f)
            parameter.targetWayPoint = parameter.wayPoint2;

        //巡逻行为
        Vector3 direction = (parameter.targetWayPoint.position - enemybrain.transform.position).normalized;
        enemybrain.transform.rotation = Quaternion.Lerp(enemybrain.transform.rotation, Quaternion.LookRotation(direction), Time.deltaTime);
        enemybrain.transform.position += enemybrain.transform.forward * Time.deltaTime * 1.0f;

        //玩家进入攻击范围就转向玩家再喊叫警告
        if (parameter.toPlayerDistance <= parameter.ToPlayerMinDistance)
        {
            //direction = (parameter.player.position - enemybrain.transform.position).normalized;
            //enemybrain.transform.rotation = Quaternion.Lerp(enemybrain.transform.rotation, Quaternion.LookRotation(direction), 1.0f);
            //enemybrain.TransitionState(StateType.Scream);

            enemybrain.transform.LookAt(parameter.player.transform);
            enemybrain.TransitionState(StateType.Scream);
        }
    }
}

public class RunState : BaseState, IState
{
    public RunState(EnemyAI enemybrain) : base(enemybrain) { }

    public void OnEnter()
    {
       parameter.animator.SetFloat("MoveSpeed", 1.0f);

        //MonoManager.GetInstance().StartCoroutine(MoveToAttackTaget());
        parameter.navMeshAgent.SetDestination(parameter.player.position);
    }

    public void OnExit()
    {
        //parameter.navMeshAgent.isStopped = true;
        enemybrain.DisableNavgation();
    }

    public void OnUpdate()
    {
        //距离足够近就攻击玩家
        if (parameter.toPlayerDistance <= parameter.AttackRange)
            enemybrain.TransitionState(StateType.Attack1);

        //玩家逃跑就回去巡逻
        if(parameter.toPlayerDistance >= parameter.ToPlayerMaxDistance)
            enemybrain.TransitionState(StateType.Walk);
    }

    IEnumerator MoveToAttackTaget()
    {
        enemybrain.EnableNavgation();
        //enemybrain.transform.LookAt(parameter.player.transform);

        while (parameter.toPlayerDistance > parameter.AttackRange)
        {
            parameter.navMeshAgent.SetDestination(parameter.player.position);
            yield return null;
        }
            
        enemybrain.DisableNavgation();
    }
}

public class ScreamState : BaseState, IState
{
    public ScreamState(EnemyAI enemybrain) : base(enemybrain) { }

    public void OnEnter()
    {
        parameter.animator.SetBool("Scream", true);
    }

    public void OnExit()
    {
        parameter.animator.SetBool("Scream", false);
    }

    public void OnUpdate()
    {
        //播放完喊叫动画,再根据距离确定是追击玩家还是直接攻击
        if (parameter.animator.GetCurrentAnimatorStateInfo(0).normalizedTime > 1.0f)
        {
            if (parameter.toPlayerDistance > parameter.AttackRange)
                enemybrain.TransitionState(StateType.Run);
            else
                enemybrain.TransitionState(StateType.Attack1);
        }
    }
}

public class Attack1State : BaseState, IState
{
    public Attack1State(EnemyAI enemybrain) : base(enemybrain) { }

    public void OnEnter()
    {
        enemybrain.DisableNavgation();
        parameter.animator.SetFloat("MoveSpeed", 0);
        parameter.animator.SetTrigger("Attack1");
    }

    public void OnExit()
    {
        
    }

    public void OnUpdate()
    {
        enemybrain.DisableNavgation();

        //玩家离开攻击范围就追击
        if (parameter.toPlayerDistance >= parameter.AttackRange)
        {
            //if(parameter.AnimationIsFinish)
                enemybrain.TransitionState(StateType.Run);
        }   
        else
            enemybrain.TransitionState(StateType.Attack2);

        //玩家逃跑就回去巡逻
        if (parameter.toPlayerDistance >= parameter.ToPlayerMaxDistance)
            enemybrain.TransitionState(StateType.Walk);
    }
}

public class Attack2State : BaseState, IState
{
    public Attack2State(EnemyAI enemybrain) : base(enemybrain) { }

    public void OnEnter()
    {
        enemybrain.DisableNavgation();
        parameter.animator.SetFloat("MoveSpeed", 0);
        parameter.animator.SetTrigger("Attack2");
    }

    public void OnExit()
    {
        
    }

    public void OnUpdate()
    {
        enemybrain.DisableNavgation();

        //玩家离开攻击范围就追击
        if (parameter.toPlayerDistance >= parameter.AttackRange)
        {
            //if(parameter.AnimationIsFinish)
                enemybrain.TransitionState(StateType.Run);
        }  
        else
            parameter.animator.SetTrigger("Attack2");

        //玩家逃跑就回去巡逻
        if (parameter.toPlayerDistance >= parameter.ToPlayerMaxDistance)
            enemybrain.TransitionState(StateType.Walk);
    }
}