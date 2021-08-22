/*
 * FileName:      PlayerHPSlider.cs
 * Author:        天璇
 * Date:          2021/01/13 19:37:21
 * UnityVersion:  2019.4.0f1
 */
using System.Collections;
using System.Collections.Generic;
using _Scripts.角色控制;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class PlayerHPSlider : MonoBehaviour
{
    public Slider hpSlider;
    public TextMeshProUGUI hpText;
    public float currentHp;
    private string maxHP;

    private void Start()
    {
        GetComponent<ActorManager>().stateManager.HPEvent += UpdateHP;
        maxHP = GetComponent<ActorManager>().stateManager.maxHP.ToString();
    }

    void Update()
    {
        hpSlider.value = currentHp;
        hpText.text = currentHp.ToString() + "/" + maxHP;
    }

    private void OnDestroy()
    {
        GetComponent<ActorManager>().stateManager.HPEvent -= UpdateHP;
    }

    public void UpdateHP(float _value)
    {
        currentHp = _value;
    }
}
