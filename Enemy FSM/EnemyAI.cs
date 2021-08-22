using System;
using System.Collections;
using System.Collections.Generic;
using _Scripts.角色控制;
using UnityEngine;
using UnityEngine.AI;

namespace _Scripts.Enemy_FSM
{
    public enum StateType
    { 
        Idle,Walk,Run, Scream,Attack1, Attack2
    }

    [Serializable]
    public class Parameter
    {
        public int health;
        public float moveSpeed;

        public Animator animator;

        public NavMeshAgent navMeshAgent;

        [Header("巡逻路点")]
        public Transform wayPoint1;
        public Transform wayPoint2;
        public Transform targetWayPoint;

        public Transform player;
        public float toPlayerDistance;
        public readonly float AttackRange = 0.5f;
        public readonly float ToPlayerMinDistance = 5.0f;
        public readonly float ToPlayerMaxDistance = 10.0f;
    }

    public class EnemyAI : Actor
    {
        public Parameter parameter;

        private IState _currentState;

        private readonly Dictionary<StateType, IState> _states = new Dictionary<StateType, IState>();
    

        private void Awake()
        {
            parameter.animator = GetComponentInChildren<Animator>();
            parameter.player = GameObject.FindGameObjectWithTag("Player").transform;
            parameter.navMeshAgent = gameObject.AddComponent<NavMeshAgent>();
            parameter.navMeshAgent.stoppingDistance = parameter.AttackRange;
        }

        private void Start()
        {
            //创建所有状态的引用
            _states.Add(StateType.Idle, new IdleState(this));
            _states.Add(StateType.Walk, new WalkState(this));
            _states.Add(StateType.Run, new RunState(this));
            _states.Add(StateType.Scream, new ScreamState(this));
            _states.Add(StateType.Attack1, new Attack1State(this));
            _states.Add(StateType.Attack2, new Attack2State(this));

            //状态机初始状态
            TransitionState(StateType.Walk);
        }

        private void Update()
        {
            //帧更新与玩家的距离
            parameter.toPlayerDistance = Vector3.Distance(transform.position, parameter.player.position);

            //帧更新当前状态的OnUpdate方法
            _currentState.OnUpdate();

            print(_currentState.ToString());
        }

        public void TransitionState(StateType type)
        {
            //调用当前状态的OnExit方法
            _currentState?.OnExit();

            //将当前状态变为需要转换的状态，并调用新状态的OnEnter方法
            _currentState = _states[type];
            _currentState?.OnEnter();
        }

        /// <summary>
        /// 敌人在攻击时自动面向玩家
        /// </summary>
        public void AutoRotate()
        {
            var transform1 = transform;
            Vector3 derection = (parameter.player.position - transform1.position).normalized;
            derection.y = 0;
            transform.rotation = Quaternion.Lerp(transform1.rotation, Quaternion.LookRotation(derection), 0.3f);
        }

        /// <summary>
        /// 激活寻路
        /// </summary>
        public void EnableNavgation()
        {
            parameter.navMeshAgent.isStopped = false;
            parameter.navMeshAgent.updatePosition = true;
        }

        /// <summary>
        /// 关闭寻路
        /// </summary>
        public void DisableNavgation()
        {
            parameter.navMeshAgent.destination = transform.position;
            parameter.navMeshAgent.ResetPath();
            parameter.navMeshAgent.isStopped = true;
            parameter.navMeshAgent.updatePosition = false;
        }
    }
}