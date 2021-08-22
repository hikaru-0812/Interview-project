using System;
using SkillTimeLine;
using UnityEngine;

/*
 * 重构思路：
 * 提取ICharacterController类作为玩家和敌人的父类
 * 
 */
namespace _Scripts.角色控制
{
    public class ActorController : Actor
    {
        [Header("攀爬相关")]
        [Range(0.5f, 1.0f)] public float toWallRayLength = 0.5f;
        [Range(0.0f, 0.5f)] public float wallOffset = 0.5f;
        [SerializeField] private bool onWall = false;
        public Transform climbCheckPoint;
        private Vector3 _bodyTargetPos = Vector3.zero;

        [Header("相机相关")]
        public CameraController cameraController;

        [Header("UI相关")]
        public GameObject myBag;
        public GameObject pausePanel;
        

        #region 生命周期函数

        private void Awake()
        {
            //获取输入系统
            InputSystem = new KeyboardInput(transform);
            if (InputSystem == null)
                throw new ArgumentOutOfRangeException($"输入系统不存在");

            Rb = GetComponent<Rigidbody>();
            animator = GetComponentInChildren<Animator>();
            AnimationPlayAble = GetComponentInChildren<DirectorManager>();
            cameraController = GameObject.Find("CameraPos").GetComponent<CameraController>();

            //if (birth != null)
            //    transform.position = birth.position;

            //myBag = GameObject.Find(@"Canvas/Bag");
        }

        private void FixedUpdate()
        {
            Rb.position += DelatPos;
            Rb.velocity = new Vector3(planarVec.x, Rb.velocity.y, planarVec.z) + thrustVec;
            thrustVec = Vector3.zero;
            DelatPos = Vector3.zero;
        }

        private void Update()
        {
            //------动画切换------//

            //跑步
            // animator.SetFloat(HashIDs.speedFloat, InputSystem.DirectionMag * Mathf.Lerp(animator.GetFloat(HashIDs.speedFloat), (InputSystem.IsRun) ? 2.0f : 1.0f, 0.5f));
            if (InputSystem.IsRun)
            {
                AnimationPlayAble.ChangeAnimationClip(ClipName.Run);
            }
            else
            {
                AnimationPlayAble.ChangeAnimationClip(ClipName.Idle);
            }

            //翻滚
            if (Rb.velocity.magnitude > 10.0f)
                animator.SetTrigger(HashIDs.RollTrigger);

            //休息
            if (animator.GetFloat(HashIDs.speedFloat) > 0.1f)
                animator.SetBool(HashIDs.RestBool, false);

            switch (InputSystem.IsJump)
            {
                //向前跳
                case true when animator.GetFloat(HashIDs.speedFloat) > 0.1f:
                    animator.SetTrigger(HashIDs.Jump_FTrigger);
                    break;
                //原地跳
                case true:
                    animator.SetTrigger(HashIDs.JumpTigger);
                    break;
                //闪避
                default:
                {
                    if (true == InputSystem.IsDodge)
                        animator.SetTrigger(HashIDs.DodgeTrigger);
                    //攻击
                    else if (true == InputSystem.IsAttack)
                    {
                        LockEnemy();

                        animator.SetTrigger("Attack");
                    }
                    //重击
                    else if (true == InputSystem.IsHeavyAttack)
                    {
                        animator.SetTrigger(HashIDs.HeavyAttackTrigger);
                    }

                    break;
                }
            }

            //防御
            animator.SetBool(HashIDs.defenseBool, InputSystem.IsDefense);

            //盾反
            if (InputSystem.IsCounterBack)
                animator.SetTrigger(HashIDs.counterBackTrigger);

            //背包
            if(true == InputSystem.IsOpenBag)
            {
                myBag.SetActive(true);
                Cursor.lockState = CursorLockMode.None;
                InventoryManager.RefreshItem();
                Time.timeScale = 0;
            }

            //暂停
            if (Input.GetKeyDown(KeyCode.Escape))
            {
                pausePanel.SetActive(true);
                Cursor.lockState = CursorLockMode.None;
                InventoryManager.RefreshItem();
                Time.timeScale = 0;
            }

            //旋转
            if (InputSystem.DirectionMag > 0.1f && false == onWall)
            {
                Vector3 targetForward = Vector3.Slerp(model.transform.forward, InputSystem.MoveDirecion, 0.4f);
                model.transform.forward = targetForward;
            }

            //更新移动方向
            if (false == lockPlanar)
            {
                if (onWall)
                    transform.position += new Vector3(InputSystem.PlayerDirecitonRight, InputSystem.PlayerDirecitonUp, 0) * moveVelocity * Time.deltaTime;
                else
                    planarVec = InputSystem.DirectionMag * InputSystem.MoveDirecion * moveVelocity * ((InputSystem.IsRun) ? 2.0f : 1.0f);
            }

            //爪巴
            CheckClimb();

            if (!InputSystem.IsSkillOn) return;
            Transform weaponModle = transform.DeepFind("WeaponHandle").GetChild(0).GetChild(0).GetChild(0);
            GameObject fireEffectPrefab = Resources.Load("Effect7") as GameObject;

            if (weaponModle.childCount == 0)
            {
                var fireEffect = Instantiate(fireEffectPrefab, weaponModle);
                fireEffect.GetComponent<PSMeshRendererUpdater>().UpdateMeshEffect(fireEffect.transform.parent.gameObject);
            }
            else
                Destroy(weaponModle.GetChild(0).gameObject);
        }

        #endregion
        
        
        #region 爬山功能模块

        /// <summary>
        /// 检测爬山
        /// </summary>
        /// <returns></returns>
        private bool CheckClimb()
        {
            if (Physics.Raycast(transform.position + Vector3.up, model.transform.forward, out RaycastHit hitInfo, toWallRayLength) && false == InputSystem.IsQuietClimb)
            {
                if (hitInfo.transform.gameObject.CompareTag(TagAndLayer.TagWall))
                    Climb(hitInfo);
                return true;
            }

            animator.SetBool(HashIDs.isClimbBool, false);
            onWall = false;
            Rb.isKinematic = false;
            return false;
        }

        private void Climb(RaycastHit hitInfo)
        {
            InputSystem.IsQuietClimb = false;
            _bodyTargetPos = hitInfo.point + hitInfo.normal * wallOffset;

            //使人物的身体靠在山上
            if (!onWall)
                SetBodyPositionToWall();
            else
                FixBodyPos();

            animator.SetBool(HashIDs.isClimbBool, true);
            Rb.isKinematic = true;
        }

        private void SetBodyPositionToWall()
        {
            onWall = true;

            if (Vector3.Distance(transform.position, _bodyTargetPos) < 0.01f)
            {
                transform.position = _bodyTargetPos;
                return;
            }

            transform.position = Vector3.MoveTowards(transform.position, _bodyTargetPos, 0.02f);
        }

        private void FixBodyPos()
        {
            Vector3 localCheckClimbPos = transform.InverseTransformPoint(climbCheckPoint.position);
            Vector3 localHeadPos = new Vector3(localCheckClimbPos.x, localCheckClimbPos.y, 0);
            Vector3 bodyPos = transform.TransformPoint(localHeadPos);

            if (Physics.SphereCast(bodyPos, 0.1f, transform.forward, out RaycastHit hitInfo, 0.3f))
            {
                Vector3 tempPos = transform.position - climbCheckPoint.position;

                if (Vector3.Distance(transform.position, hitInfo.point + tempPos) > 0.05f)
                    transform.position = hitInfo.point + tempPos;
            }
        }

        #endregion

        
        #region 动画事件回调

        public void OnJumpEnter()
        {
            thrustVec = new Vector3(0, jumpVelocity, 0);
            InputSystem.InputEnable = false;
            lockPlanar = true;
            InputSystem.IsQuietClimb = false;
            isGround = false;
        }

        //public void IsGround()
        //{
        //    animator.SetBool(HashIDs.IsGroundBool, true);
        //    isGround = true;
        //}

        //public void IsNotGround()
        //{
        //    animator.SetBool(HashIDs.IsGroundBool, false);
        //    isGround = false;
        //}

        public void OnGroundEnter()
        {
            animator.SetBool(HashIDs.IsGroundBool, true);
            InputSystem.InputEnable = true;
            InputSystem.IsQuietClimb = true;
            lockPlanar = false;
            onWall = false;
            isGround = true;
        }

        public void OnGroundExit()
        {
            animator.SetBool(HashIDs.IsGroundBool, false);
            isGround = false;
        }

        //Roll
        public void OnRollEnter()
        {
            thrustVec = new Vector3(rollVelocity, 1.0f, 0);
            InputSystem.InputEnable = false;
            lockPlanar = true;
        }

        //Climb
        public void OnClimbEnter()
        {
            InputSystem.InputEnable = true;
            lockPlanar = false;
            isGround = false;
            InputSystem.IsQuietClimb = false;
        }

        //ForwardDodge
        public void OnForwardDodgeEnter()
        {
            InputSystem.InputEnable = false;
            lockPlanar = true;
            InputSystem.IsQuietClimb = false;
        }

        public void OnForwardDodgeUpdate()
        {
            thrustVec = model.transform.forward * -animator.GetFloat(HashIDs.forwardDodgeVelocityFloat) * dodgeVelocity;
        }

        //BackwardDodge
        public void OnBackwardDodgeEnter()
        {
            InputSystem.InputEnable = false;
            lockPlanar = true;
            InputSystem.IsQuietClimb = false;
        }

        public void OnBackwardDodgeUpdate()
        {
            thrustVec = model.transform.forward * animator.GetFloat(HashIDs.backwardDodgeVelocityFloat) * dodgeVelocity;
        }

        //Attack
        public void OnAttackEnter()
        {
            InputSystem.InputEnable = false;

            //if (false == isGround)
            //{
            //    rb.useGravity = false;
            //    rb.velocity = Vector3.zero;
            //}
        }

        public void OnAttackUpdate()
        {
            thrustVec = model.transform.forward * animator.GetFloat(HashIDs.AttackVelocityFloat);
        }

        public void OnAttackExit()
        {
            //model.SendMessage("WeaponDisable");
        }

        public void InputSystemDisable()
        {
            InputSystem.InputEnable = false;

            //瞬间失去速度
            planarVec = Vector3.zero;
            lockPlanar = true;

            //确保关闭武器触发器
            model.SendMessage("WeaponDisable");
        }

        public void InputSystemEnable()
        {
            InputSystem.InputEnable = true;
            lockPlanar = false;
        }

        public void OnSwimEnter()
        {
            InputSystemEnable();
        }

        public void OnHitEnter()
        {
            GetComponent<ActorManager>().stateManager.isAttacked = true;
        }

        public void OnHitExit()
        {
            GetComponent<ActorManager>().stateManager.isAttacked = false;
        }

        //应用根位移
        public void OnUpdateRootMotion(object delatPostion)
        {
            //只在攻击时应用根位移(加一个适当的权重)
            if (animator.CheckStateTag(HashIDs.attackTag))
                DelatPos += 1f * (Vector3)delatPostion;
        }

        #endregion

        
        #region 外部调用

        public void RevivePlayer()
        {
            //transform.position = birth.position;
            animator.SetTrigger("Revive");
        }
        
        public void SetTrigger(int triggerNameHash)
        {
            animator.SetTrigger(triggerNameHash);
        }

        public void ChangeBool(int boolNameHash, bool value)
        {
            animator.SetBool(boolNameHash, value);
        }

        #endregion

        
        #region 内部调用

        /// <summary>
        /// 自动朝向敌人
        /// </summary>
        private void LockEnemy()
        {
            Transform target = null;
            var raycastHits = Physics.BoxCastAll(model.transform.position, new Vector3(5f, 5f, 5f), model.transform.rotation.eulerAngles, Quaternion.identity, 10.0f, LayerMask.GetMask(TagAndLayer.LayerEnemy));

            if (raycastHits.Length > 0)
                target = raycastHits[0].transform;

            foreach (var item in raycastHits)
            {
                if (!(target is null) && Vector3.Distance(model.transform.position, item.transform.position) < Vector3.Distance(model.transform.position, target.position))
                    target = item.transform;
            }

            if (target == null) return;
            Vector3 direction = (target.position - model.transform.position).normalized;
            direction.y = 0;
            model.transform.rotation = Quaternion.LookRotation(direction);
        }

        // private void Attack()
        // {
        //     #region int属性实现
        //     //timer.StartTickTock(1.0f);
        //     //if (stateInfol.IsName(HashIDs.locomotion) && stateInfol.normalizedTime > 0.01f) comb = 1;
        //     //if (stateInfol.IsName(HashIDs.attack1) && stateInfol.normalizedTime > 0.65f) comb = 2;
        //     //if (stateInfol.IsName(HashIDs.attack2) && stateInfol.normalizedTime > 0.65f) comb = 3;
        //     //if (stateInfol.IsName(HashIDs.attack3) && stateInfol.normalizedTime > 0.65f) comb = 4;
        //     //if (stateInfol.IsName(HashIDs.attack4) && stateInfol.normalizedTime > 0.65f) comb = 5;
        //     //if (stateInfol.IsName(HashIDs.attack5) && stateInfol.normalizedTime > 0.65f) comb = 1;
        //
        //     //animator.SetInteger(HashIDs.AttackInteger, comb);
        //     #endregion
        // }

        #endregion
    }
}
