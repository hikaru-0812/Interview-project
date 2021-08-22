/*
 *FileName:      IUseerInput.cs
 *Author:        天璇
 *Date:          2020/12/15 10:08:09
 *UnityVersion:  2019.4.0f1
 *
 * 依赖倒置原则
 * 单一职责原则
 * 只负责将各种输入信号整合成向量输出(*Arduino控制器)
*/

using UnityEngine;

namespace _Scripts.角色控制
{
    /// <summary>
    /// 所有输入系统的父类
    /// </summary>
    public abstract class UserInput
    {
        private readonly Transform _transform;
        
        [Header("所有功能按键")]
        protected readonly MyButton BtnOpenBag = new MyButton();
        protected readonly MyButton BtnQuietClimb = new MyButton();
        protected readonly MyButton BtnJump = new MyButton();
        protected readonly MyButton BtnRun = new MyButton();
        protected readonly MyButton BtnDodge = new MyButton();
        protected readonly MyButton BtnAttack = new MyButton();
        protected readonly MyButton BtnHeavyAttack = new MyButton();
        protected readonly MyButton BtnSkill = new MyButton();
        protected readonly MyButton BtnDefense = new MyButton();
        protected readonly MyButton BtnCounterBack = new MyButton();
        protected readonly MyButton BtnInteractive = new MyButton();

        [Header("输入系统开关")]
        public bool InputEnable = true;

        [Header("输入信号")]
        public float PlayerDirecitonUp;
        public float PlayerDirecitonRight;
        protected float CameraDirectionUp;
        protected float CameraDirectionRight;
        private float _xSensitivity = 1.0f; //相机x轴灵敏度
        private float _ySensitivity = 1.0f; //相机y轴灵敏度
        public float XSensitivity
        {
            get => _xSensitivity;
            set => _xSensitivity = value;
        }

        public float YSensitivity
        {
            get => _ySensitivity;
            set => _ySensitivity = value;
        }
        
        /// <summary>
        /// 角色移动向量模长
        /// </summary>
        public float DirectionMag;

        /// <summary>
        /// 角色移动向量方向
        /// </summary>
        public Vector3 MoveDirecion;

        /// <summary>
        /// 相机旋转方向
        /// </summary>
        public Vector3 CameraRotation;

        /// <summary>
        /// 缓存输入信号
        /// </summary>
        private Vector2 _tempAxis;

        [Header("状态")]
        //1.pressing signal
        public bool IsRun = false;
        public bool IsDefense = false;
        //2.trigger once signal
        public bool IsOpenBag = false;
        public bool IsJump = false;
        public bool IsQuietClimb = true;
        public bool IsDodge = false;
        public bool IsAttack = false;
        public bool IsHeavyAttack = false;
        public bool IsSkillOn = false;
        public bool IsCounterBack = false;
        public bool IsInteractive = false;

        protected UserInput(Transform ownTransform)
        {
            _transform = ownTransform;
        }


        /// <summary>
        /// 将输入信号处理后输出信号
        /// </summary>
        protected void Output()
        {
            //处理输入信号
            _tempAxis = SquareToCircle(new Vector2(PlayerDirecitonRight, PlayerDirecitonUp));
            PlayerDirecitonRight = _tempAxis.x;
            PlayerDirecitonUp = _tempAxis.y;

            //如果输入系统没有被关闭
            if (InputEnable == false)
            {
                PlayerDirecitonUp = 0;
                PlayerDirecitonRight = 0;
                CameraDirectionRight = 0;
                CameraDirectionUp = 0;
            }

            //输出信号
            DirectionMag = Mathf.Sqrt((PlayerDirecitonUp * PlayerDirecitonUp) + (PlayerDirecitonRight * PlayerDirecitonRight));//勾股定理
            MoveDirecion = PlayerDirecitonRight * _transform.right + PlayerDirecitonUp * _transform.forward;
            CameraRotation = CameraDirectionRight * Vector3.right * _xSensitivity + CameraDirectionUp * Vector3.forward * _ySensitivity;
        }

        /// <summary>
        /// 解决斜45度移动1.414倍速度的问题
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        private Vector2 SquareToCircle(Vector2 input)
        {
            Vector2 output = Vector2.zero;

            output.x = input.x * Mathf.Sqrt(1 - (input.y * input.y) / 2.0f);
            output.y = input.y * Mathf.Sqrt(1 - (input.x * input.x) / 2.0f);

            return output;
        }
    }
}
