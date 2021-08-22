using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraOffset : MonoBehaviour
{
    Transform Player;
    [SerializeField]public float smoothTime = 0;
    [SerializeField]private Vector3 transformOffset = Vector3.zero;

    // Start is called before the first frame update
    void Start()
    {
        Player = GameObject.FindGameObjectWithTag("Player").transform;
        transformOffset = transform.position - Player.position;
    }

    // Update is called once per frame
    void LateUpdate()
    {
        transform.position = Vector3.Lerp(transform.position, Player.position + transformOffset, smoothTime * Time.deltaTime);
    }
}
