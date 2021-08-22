/*
 *FileName:      JoystickInput.cs
 *Author:        天璇
 *Date:          2020/12/15 22:48:06
 *UnityVersion:  2019.4.0f1
 *
 * 单一职责原则
 * 只负责手柄输入
 */
using System.Collections;
using System.Collections.Generic;
using _Scripts.角色控制;
using UnityEngine;

public class JoystickInput : UserInput
{
    void Update()
    {
        //btnOpenBag.Tick(Input.GetKey(KeyCode.Tab));
        //btnQuietClimb.Tick(Input.GetKey(KeyCode.X));
        //btnJump.Tick(Input.GetKey(KeyCode.Space));
        //btnRun.Tick(Input.GetKey(KeyCode.LeftShift));
        //btnDodge.Tick(Input.GetMouseButton(1));
        //btnAttack.Tick(Input.GetMouseButton(0));
        //btnSkill.Tick(Input.GetKey(KeyCode.Q));
        //btnDefense.Tick(Input.GetKey(KeyCode.E));
        //btnCounterBack.Tick(Input.GetMouseButton(2));
        //btnInteractive.Tick(Input.GetKey(KeyCode.F));

        //if (Input.GetButton("Jump"))
        //    print("SB");

        //输入 (控制移动)
        PlayerDirecitonUp = Input.GetAxis("axisY");
        PlayerDirecitonRight = Input.GetAxis("axisX");
        CameraDirectionUp = Input.GetAxis("axis5");
        CameraDirectionRight = Input.GetAxis("axis4");

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

        Output();
    }

    public JoystickInput(Transform ownTransform) : base(ownTransform)
    {
    }
}
