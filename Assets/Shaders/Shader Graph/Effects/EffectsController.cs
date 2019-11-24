using UnityEngine;

public class EffectsController : MonoBehaviour
{
    [SerializeField] Material shakeMaterial;

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            shakeMaterial.SetFloat("_ShakeTime", Time.time);
        }
    }
}
