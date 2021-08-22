/*
 *FileName:      KeyboardInputSystem.cs
 *Author:        天璇
 *Date:          2020/12/15 12:38:17
 *UnityVersion:  2019.4.0f1
 */

using MyUnityFramework;
using UnityEngine;

/*
 * 单一职责原则
 * 只负责键盘输入
 */

namespace _Scripts.角色控制
{
    public class KeyboardInput : UserInput
    {
        private void Update()
        {
            BtnOpenBag.Tick(Input.GetKey(KeyCode.Tab));
            BtnQuietClimb.Tick(Input.GetKey(KeyCode.X));
            BtnJump.Tick(Input.GetKey(KeyCode.Space));
            BtnRun.Tick(Input.GetKey(KeyCode.LeftShift));
            BtnDodge.Tick(Input.GetMouseButton(1));
            BtnAttack.Tick(Input.GetMouseButton(0));
            BtnSkill.Tick(Input.GetKey(KeyCode.Q));
            BtnDefense.Tick(Input.GetKey(KeyCode.E));
            BtnCounterBack.Tick(Input.GetMouseButton(2));
            BtnInteractive.Tick(Input.GetKey(KeyCode.F));

            //输入 (控制移动)
            //direcitonUp = (Input.GetKey(keyUp) ? 1.0f : 0) - (Input.GetKey(keyDown) ? 1.0f : 0);
            PlayerDirecitonUp = Input.GetAxis("Vertical");
            PlayerDirecitonRight = Input.GetAxis("Horizontal");
            CameraDirectionUp = Input.GetAxis("Mouse Y");
            CameraDirectionRight = Input.GetAxis("Mouse X");

            //状态开关
            IsOpenBag = BtnOpenBag.OnPressed;
            IsQuietClimb = BtnQuietClimb.OnPressed;
            IsJump = BtnJump.OnPressed;
            IsRun = BtnRun.IsHolding;
            IsDodge = BtnDodge.OnPressed;
            IsAttack = BtnAttack.OnPressed;
            IsHeavyAttack = BtnAttack.IsPressing;
            IsSkillOn = BtnSkill.OnPressed;
            IsDefense = BtnDefense.IsHolding;
            IsCounterBack = BtnCounterBack.OnPressed;
            IsInteractive = BtnInteractive.OnPressed;

            //if (true == btnOpenBag.OnPressed)
            //    isOpenBag = !isOpenBag;
            //print(isOpenBag);

            Output();
        }

        public KeyboardInput(Transform ownTransform) : base(ownTransform)
        {
            MonoManager.Instance.AddUpdateListener(Update);
        }
    }
}
