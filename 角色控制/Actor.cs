using SkillTimeLine;
using UnityEngine;

namespace _Scripts.角色控制
{
    public class Actor : MonoBehaviour
    {
        public UserInput InputSystem;
        
        [Header("移动相关")]
        public GameObject model;
        [Range(0.0f, 5.0f)] public float moveVelocity = 2.4f;
        [SerializeField] protected Vector3 planarVec;//移动动量

        [Range(0.0f, 5.0f)] public float jumpVelocity = 2.0f;
        [Range(0.0f, 5.0f)] public float rollVelocity = 1.0f;
        [Range(0.5f, 5.0f)] public float dodgeVelocity = 3.0f;
        [SerializeField] protected Vector3 thrustVec;//冲量

        protected Rigidbody Rb;
        [SerializeField] protected bool lockPlanar = false;
        public bool isGround = true;

        [Header("动画相关")]
        public Animator animator;
        protected DirectorManager AnimationPlayAble;
        protected Vector3 DelatPos;//动画根运动的位移
    }
}