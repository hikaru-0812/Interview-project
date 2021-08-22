using UnityEngine;

public class IKAnimation : MonoBehaviour
{
    private Animator animator;

    [Header("IK开关")]
    public bool IKEnable = true;

    [Header("看向的目标")]
    public Transform lookTarget;

    //[Header("足IK")]
    //[SerializeField] private Transform leftFootIKPoint;
    //[SerializeField] private Transform rightFootIKPoint;

    //[Header("侦测斜坡")]
    //public Transform groundCheck;
    //public float rayLength = 0.5f;
    //public float currentSlopAngle = 0f;
    //public float maxSlopAngle = 30f;
    //private Vector3 slopHitNormal = Vector3.zero;
    //public Transform model;

    //public Vector3 angle;
    //private Transform RightHand;

    /// <summary>
    /// 射线检测IK位置
    /// </summary>
    private Vector3 LeftFootIK, RightFootIK;
    /// <summary>
    /// IK位置
    /// </summary>
    private Vector3 LeftFootPos, RightFootPos;
    /// <summary>
    /// IK旋转
    /// </summary>
    private Quaternion LeftFootRot, RightFootRot;

    /// <summary>
    /// IK交互层
    /// </summary>
    public LayerMask EnvLayer;
    /// <summary>
    /// 脚部IK位置与实际射线检测位置的Y轴差
    /// </summary>
    [Range(0, 0.2f)] public float GroundOffset;
    /// <summary>
    /// 射线向下检测距离
    /// </summary>
    public float GroundDistance;

    private void Awake()
    {
        animator = GetComponent<Animator>();
        //model = /*GameObject.Find("CameraPos").GetComponent<CameraController>().modle.transform;*/transform;
    }

    private void FixedUpdate()
    {
        Debug.DrawLine(LeftFootIK + Vector3.up, LeftFootIK + Vector3.down * GroundDistance, Color.blue, Time.fixedDeltaTime);
        Debug.DrawLine(RightFootIK + Vector3.up, RightFootIK + Vector3.down * GroundDistance, Color.blue, Time.fixedDeltaTime);

        if (Physics.Raycast(LeftFootIK + Vector3.up, Vector3.down, out RaycastHit hit, GroundDistance + 1, EnvLayer))
        {
            Debug.DrawRay(hit.point, hit.normal, Color.red, Time.fixedDeltaTime);

            LeftFootPos = hit.point + Vector3.up * GroundOffset;

            LeftFootRot = Quaternion.FromToRotation(Vector3.up, hit.normal) * transform.rotation;
        }

        if (Physics.Raycast(RightFootIK + Vector3.up, Vector3.down, out RaycastHit hit1, GroundDistance + 1, EnvLayer))
        {
            Debug.DrawRay(hit1.point, hit1.normal, Color.red, Time.fixedDeltaTime);

            RightFootPos = hit1.point + Vector3.up * GroundOffset;

            RightFootRot = Quaternion.FromToRotation(Vector3.up, hit1.normal) * transform.rotation;
        }

        print("LeftFootRot:" + LeftFootRot);
        print("RightFootRot:" + RightFootRot);
    }

    private void OnAnimatorIK(int layerIndex)
    {
        #region 失败逻辑
        //if (true == IKEnable && true == OnSlop()/*检测坡度*/ && model.parent.GetComponent<ActorController>().inputSystem.directionMag == 0)
        //{
        //    //if (null != leftFootIKPoint && null != rightFootIKPoint)
        //    //{
        //    //    animator.SetIKPositionWeight(AvatarIKGoal.LeftFoot, 1);
        //    //    animator.SetIKPositionWeight(AvatarIKGoal.RightFoot, 1);

        //    //    if (Physics.Raycast(new Ray(leftFootIKPoint.position, Vector3.down), out RaycastHit leftHitInfo, rayLength))
        //    //    {
        //    //        Debug.DrawRay(leftFootIKPoint.position, leftHitInfo.point - leftFootIKPoint.position, Color.red);
        //    //        animator.SetIKPosition(AvatarIKGoal.LeftFoot, leftHitInfo.point + new Vector3(0, 0.1f, 0));
        //    //    }
        //    //    if (Physics.Raycast(new Ray(rightFootIKPoint.position, Vector3.down), out RaycastHit rightHitInfo, rayLength))
        //    //    {
        //    //        Debug.DrawRay(rightFootIKPoint.position, rightHitInfo.point - rightFootIKPoint.position, Color.red);
        //    //        animator.SetIKPosition(AvatarIKGoal.RightFoot, rightHitInfo.point + new Vector3(0, 0.1f, 0));
        //    //    }
        //    //}
        //    //else
        //    //{
        //    //    animator.SetIKPositionWeight(AvatarIKGoal.LeftFoot, 0);
        //    //    animator.SetIKPositionWeight(AvatarIKGoal.RightFoot, 0);
        //    //    //animator.SetIKRotationWeight(AvatarIKGoal.LeftFoot, 0);
        //    //    //animator.SetIKRotationWeight(AvatarIKGoal.RightFoot, 0);
        //    //}

        //    #region
        //    //RightHand = animator.GetBoneTransform(HumanBodyBones.RightHand);
        //    //RightHand.localEulerAngles += angle;
        //    //animator.SetBoneLocalRotation(HumanBodyBones.RightHand, Quaternion.Euler(RightHand.localEulerAngles));
        //    #endregion
        //}
        #endregion

        //看向目标
        //if (null != lookTarget)
        //{
        //    animator.SetLookAtWeight(0.5f);
        //    animator.SetLookAtPosition(lookTarget.position);
        //}

        #region 失败逻辑
        //脚掌匹配坡度
        //leftFootIKPoint.eulerAngles = new Vector3(-currentSlopAngle, model.rotation.eulerAngles.y, 0);
        //rightFootIKPoint.eulerAngles = new Vector3(-currentSlopAngle, model.rotation.eulerAngles.y, 0);
        //animator.SetIKRotationWeight(AvatarIKGoal.LeftFoot, 1);
        //animator.SetIKRotationWeight(AvatarIKGoal.RightFoot, 1);
        //animator.SetIKRotation(AvatarIKGoal.LeftFoot, leftFootIKPoint.rotation);
        //animator.SetIKRotation(AvatarIKGoal.RightFoot, rightFootIKPoint.rotation);
        #endregion

        LeftFootIK = animator.GetIKPosition(AvatarIKGoal.LeftFoot);
        RightFootIK = animator.GetIKPosition(AvatarIKGoal.RightFoot);

        if (IKEnable == false)
            return;

        //animator.SetIKPositionWeight(AvatarIKGoal.LeftFoot, animator.GetFloat("LIK"));
        //animator.SetIKRotationWeight(AvatarIKGoal.LeftFoot, animator.GetFloat("LIK"));

        //animator.SetIKPositionWeight(AvatarIKGoal.RightFoot, animator.GetFloat("RIK"));
        //animator.SetIKRotationWeight(AvatarIKGoal.RightFoot, animator.GetFloat("RIK"));
        animator.SetIKPositionWeight(AvatarIKGoal.LeftFoot, 1f);
        animator.SetIKRotationWeight(AvatarIKGoal.LeftFoot, 1f);

        animator.SetIKPositionWeight(AvatarIKGoal.RightFoot, 1f);
        animator.SetIKRotationWeight(AvatarIKGoal.RightFoot, 1f);

        animator.SetIKPosition(AvatarIKGoal.LeftFoot, LeftFootPos);
        animator.SetIKRotation(AvatarIKGoal.LeftFoot, LeftFootRot);

        animator.SetIKPosition(AvatarIKGoal.RightFoot, RightFootPos);
        animator.SetIKRotation(AvatarIKGoal.RightFoot, RightFootRot);
    }

    ///// <summary>
    ///// 判断是否在坡上并检测坡度
    ///// </summary>
    ///// <returns>是否在坡上</returns>
    //bool OnSlop()
    //{
    //    if (Physics.Raycast(new Ray(groundCheck.position, Vector3.down), out RaycastHit slopHitInfo, rayLength))
    //    {
    //        slopHitNormal = slopHitInfo.normal;

    //        currentSlopAngle = Vector3.Angle(slopHitInfo.normal, Vector3.up);
    //        if (currentSlopAngle < maxSlopAngle && currentSlopAngle > 0)
    //            return true;
    //    }

    //    return false;
    //}

    public void SetLookTarget(Transform _lookTargetPos)
    {
        lookTarget = _lookTargetPos;
    }
}
