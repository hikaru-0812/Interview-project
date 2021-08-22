/*
 *FileName:      MyTimer.cs
 *Author:        天璇
 *Date:          2020/12/17 09:23:21
 *UnityVersion:  2019.4.0f1
 */
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyTimer : MonoBehaviour
{
    /// <summary>
    /// 需要持续的时间
    /// </summary>
    private float m_durationTime = 0.0f;

    /// <summary>
    /// 已经经过的时间
    /// </summary>
    private float m_elapsedTime = 0.0f;

    /// <summary>
    /// 记录计时器开始的时间
    /// </summary>
    float m_startTime = 0.0f;

    bool timeUp = false;
    bool coroutineStarted = false;

    public float ElapsedTime { get => m_elapsedTime; }

    public bool TimeUp { get => timeUp; }

    private IEnumerator TickTock()
    {
        //Debug.Log("开始计时......");
        coroutineStarted = true;
        while (false == timeUp)
        {
            yield return new WaitForSeconds(Time.deltaTime);
            //currentTime += Time.deltaTime;
            m_elapsedTime = Time.time - m_startTime;
            if (m_elapsedTime >= m_durationTime && m_durationTime != 0)
                break;
        }
        EndTickTock();
    }

    public void StartTickTock(float _durationTime)
    {
        InitTickTock();
        m_durationTime = _durationTime;
        if (false == coroutineStarted)
            StartCoroutine(TickTock());
    }

    public void EndTickTock()
    {
        //Debug.Log("结束计时......");
        timeUp = true;
        coroutineStarted = false;
    }

    public void InitTickTock()
    {
        m_elapsedTime = 0.0f;
        m_durationTime = 0.0f;
        m_startTime = Time.time;
        timeUp = false;
    }
}