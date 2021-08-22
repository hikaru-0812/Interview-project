/*
 *FileName:      MyButton.cs
 *Author:        天璇
 *Date:          2020/12/16 22:35:39
 *UnityVersion:  2019.4.0f1
 */

using System;
using DG.Tweening;
using MyUnityFramework;
using UnityEngine;

namespace _Scripts.角色控制
{
    public class MyButton 
    {
        /// <summary>
        /// 是否长按
        /// </summary>
        public bool IsPressing = false;

        /// <summary>
        /// 是否按住
        /// </summary>
        public bool IsHolding = false;

        /// <summary>
        /// 是否按下（上升沿触发）
        /// </summary>
        public bool OnPressed = false;

        /// <summary>
        /// 是否抬起（下降沿触发）
        /// </summary>
        public bool OnReleased = false;

        /// <summary>
        /// 抬起延迟（下降沿延迟触发）
        /// </summary>
        public bool IsExtending = false;

        /// <summary>
        /// 按下延迟（上升沿延迟触发）
        /// </summary>
        public bool IsDelaying = false;

        /// <summary>
        /// 当前状态
        /// </summary>
        private bool curState = false;

        /// <summary>
        /// 前一个状态
        /// </summary>
        private bool lastState = false;

        public void Tick(bool button)
        {
            curState = button;

            IsHolding = button;
            OnPressed = false;
            OnReleased = false;
            IsExtending = false;
            IsDelaying = false;

            //输入状态发生变化时
            if (curState != lastState)
            {
                if (true == curState)
                {
                    OnPressed = true;

                    Sequence seq = DOTween.Sequence();
                    seq.AppendCallback(() =>
                        {
                            //若按下按钮后经过0.5秒仍然是按下，这判定为长按
                            if (true == curState)
                                IsPressing = true;
                        }
                    ).SetDelay(0.5f);
                }
                else
                {
                    OnReleased = true;
                    IsPressing = false;
                }
            }

            //OnPressed = curState && (curState != lastState);
            //OnReleased = (!curState) && (curState != lastState);

            lastState = curState;
        }
    }
}
