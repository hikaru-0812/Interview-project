
namespace _Scripts.Enemy_FSM
{
    public abstract class BaseState
    {
        protected EnemyAI enemybrain;
        protected Parameter parameter;

        public BaseState(EnemyAI enemybrain)
        {
            this.enemybrain = enemybrain;
            this.parameter = enemybrain.parameter;
        }
    }
}
