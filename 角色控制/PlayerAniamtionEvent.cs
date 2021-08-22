/*
 * FileName:      PlayerAniamtionEvent.cs
 * Author:        天璇
 * Date:          2021/01/17 20:18:43
 * UnityVersion:  2019.4.0f1
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class PlayerAniamtionEvent : MonoBehaviour
{
    public AudioClip step1, step2;
    AudioSource audioSource;

    void Awake()
    {
        audioSource = GetComponent<AudioSource>();
    }

    public void StepSound1()
    {
        audioSource.clip = step1;
        audioSource.Play();
    }

    public void StepSound2()
    {
        audioSource.clip = step2;
        audioSource.Play();
    }
}
