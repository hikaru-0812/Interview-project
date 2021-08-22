/*
 *FileName:      ActorManager.cs
 *Author:        天璇
 *Date:          2020/12/22 19:50:56
 *UnityVersion:  2019.4.0f1
 */

using DG.Tweening;
using MyUnityFramework;
using UnityEngine;

namespace _Scripts.角色控制
{
    public class ActorManager : MonoBehaviour
    {
        public ActorController actorController;

        [Header("=== 如果没有则自动添加 ===")]
        public BattleManager battleManager;
        public WeaponManager weaponManager;
        public StateManager stateManager;

        [Space(20)]
        public GameObject damageCanvasPrefab;
        private GameObject _damageNumber;

        [Header("打击效果相关")]
        public GameObject effectPrefab;
        private ParticleSystem _effect;
        public AudioClip audio0;
        public AudioClip audio1;
        public AudioClip shieldAudio;
        private AudioSource _audioSource;

        [Space(20)]
        public CanvasGroup startPanel;

        private void Awake()
        {
            actorController = GetComponent<ActorController>();

            GameObject sensor = transform.Find("Sensor").gameObject;
            GameObject model = actorController.model;

            battleManager = Bind<BattleManager>(sensor);
            weaponManager = Bind<WeaponManager>(model);
            stateManager = Bind<StateManager>(gameObject);

            _audioSource = GetComponent<AudioSource>();
        }

        private void Start()
        {
            _effect = Instantiate(effectPrefab, transform).GetComponent<ParticleSystem>();

            if (name == "Enemy2")
                Destroy(this, 3.0f);
        }

        private void OnDestroy()
        {
            if (name == "Enemy2")
                EventManager.Instance.EventTrigger("BossDead");
        }

        /// <summary>
        /// 计算伤害
        /// </summary>
        /// <param name="enemyWc">对方的WeaponController</param>
        /// <param name="attackValid">是否真的能打中</param>
        /// <param name="counterValid">是否真的能防御</param>
        public void TryDoDamage(WeaponController enemyWc, bool attackValid, bool counterValid)
        {
            if (stateManager.isCounterBackSuccess && counterValid)//盾反成功
                enemyWc.weaponManager.actorManager.Stunned();//对方进入硬直状态

            else if (stateManager.isDefense && enemyWc.weaponManager.actorManager.stateManager.isAttack && attackValid)//防御状态受击
                DefenseHit();

            else if (stateManager.isCounterBackFailure && attackValid)//盾反失败且被打到
                HitOrDie(enemyWc, false);

            else if (stateManager.isImmortal)//处于无敌状态
                return;//不计算伤害且不切换动画

            else if(attackValid)
                HitOrDie(enemyWc, true);
        }

        /// <summary>
        /// 被盾反硬直响应方法
        /// </summary>
        private void Stunned()
        {
            actorController.SetTrigger(HashIDs.stunnedTrigger);
        }

        /// <summary>
        /// 受击响应方法
        /// </summary>
        private void Hit(int damageValue)
        {
            actorController.SetTrigger(HashIDs.HitTrigger);
            _damageNumber = Instantiate(damageCanvasPrefab, transform.position + new Vector3(Random.Range(-2.0f, 2.0f), 0, 0), Quaternion.identity);
            _damageNumber.GetComponent<UIDamageNumber>().SetDamageValue(Mathf.RoundToInt(damageValue));
        }

        /// <summary>
        /// 防御受击响应方法
        /// </summary>
        private void DefenseHit()
        {
            actorController.SetTrigger(HashIDs.defenseHitTrigger);
            _audioSource.clip = shieldAudio;
            _audioSource.Play();
        }

        /// <summary>
        /// 死亡响应方法
        /// </summary>
        private void Die()
        {
            //播放死亡动画
            actorController.SetTrigger(HashIDs.DieTrigger);

            //设置死亡布尔，禁用闪避
            actorController.ChangeBool(HashIDs.DieBool, true);

            //播放粒子特效
            GameObject disappearEffectPrefab = Resources.Load("Died Particle") as GameObject;
            ParticleSystem disappearEffect = GameObject.Instantiate(disappearEffectPrefab, transform).GetComponent<ParticleSystem>();
            disappearEffect.Play();

            //关闭受击检测触发器，防止鞭尸
            battleManager.hitCol.enabled = false;

            //死亡时解除锁定
            //if (actorController.cameraController.lockTatget != null)
            actorController.cameraController.UnLock();

            //使相机无法移动
            if (true == actorController.cameraController.isAI && actorController.cameraController != null)
                actorController.cameraController.enabled = false;

            //
            if(transform.CompareTag(TagAndLayer.TagEnemy))
                Destroy(gameObject, 3.0f);
            else if(transform.CompareTag(TagAndLayer.TagPlayer))
            {
                DOTween.Sequence()
                    .Append(DOTween.To(() => startPanel.alpha, (x) => startPanel.alpha = x, 1, 1.0f))
                    .AppendCallback(() => { actorController.RevivePlayer(); stateManager.HP = stateManager.maxHP; })
                    .Insert(2.0f, DOTween.To(() => startPanel.alpha, (x) => startPanel.alpha = x, 0, 1.0f));
            }
        }

        /// <summary>
        /// 受伤或死亡判断
        /// </summary>
        /// <param name="enemyWc"></param>
        /// <param name="doHitAnim">是否播放受击动画</param>
        private void HitOrDie(WeaponController enemyWc, bool doHitAnim)
        {
            if (stateManager.HP <= 0)
            {
                Destroy(gameObject, 3.0f);
                Die();
            }  
            else
            {
                stateManager.isAttacked = true;
                stateManager.AddHP(-1 * enemyWc.GetATK());
                stateManager.isAttacked = false;

                if (stateManager.HP > 0)
                {
                    if (true == doHitAnim)
                    {
                        Hit(enemyWc.GetATK());

                        //音效
                        _audioSource.clip = Random.Range(0f, 1f) == 1 ? audio1 : audio0;
                        _audioSource.Play();

                        if (!transform.CompareTag(TagAndLayer.TagEnemy)) return;
                        //相机震动
                        if (!(Camera.main is null))
                            Camera.main.transform.DOShakePosition(0.5f, new Vector3(0.1f, 0.1f, 0));

                        //帧冻结
                        Time.timeScale = 0.2f;
                        DOTween.Sequence().AppendCallback(() =>
                            {
                                Time.timeScale = 1;
                            }
                        ).SetDelay(0.03f);

                        //放射模糊
                        _effect.Play();
                    }
                }
                else
                    Die();
            } 
        }

        /// <summary>
        /// 盾反响应方法
        /// </summary>
        /// <param name="val"></param>
        public void SetIsCountBack(bool val)
        {
            stateManager.isCounterBackEnable = val;
        }

        /// <summary>
        /// 用于其他管理者与ActorManager的绑定，构建双向持有关系
        /// </summary>
        /// <typeparam name="T">其他管理者的类型</typeparam>
        /// <param name="obj">其他管理者要挂载的gameObject</param>
        /// <returns></returns>
        private T Bind<T>(GameObject obj) where T : IActorManager
        {
            T tempInstance = obj.GetComponent<T>();

            if (null == tempInstance)
                tempInstance = obj.AddComponent<T>();

            //双向持有
            tempInstance.actorManager = this;

            return tempInstance;
        }
    }
}
