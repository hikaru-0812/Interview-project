using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/*
 * 地面、水面检测
 */

public class OnSensor : MonoBehaviour
{
    public CapsuleCollider capsuleCollider;

    private Vector3 point1;//胶囊体下园圆心
    private Vector3 point2;//胶囊体上园圆心
    private float radius;

    void Awake()
    {
        capsuleCollider = GetComponentInParent<CapsuleCollider>();
        radius = capsuleCollider.radius - 0.05f;//缩小0.05使检测更精确
    }

    void FixedUpdate()
    {
        point1 = transform.position + transform.up * (radius - 0.1f);
        point2 = transform.position + transform.up * (capsuleCollider.height - 0.1f) - transform.up * radius;
        Collider[] colliders = Physics.OverlapCapsule(point1, point2, radius, LayerMask.GetMask("Ground"));
        if (colliders.Length != 0)
            SendMessageUpwards("OnGroundEnter");
        else
            SendMessageUpwards("OnGroundExit");
    }
}
