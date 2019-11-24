using System.Collections;
using UnityEngine;

public class EffectsController : MonoBehaviour
{
    [SerializeField] Material shakeMaterial;

    private void Start()
    {
        StartCoroutine(ShakeIt());
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            shakeMaterial.SetFloat("_ShakeTime", Time.time);
        }
    }

    IEnumerator ShakeIt()
    {
        while (true)
        {
            shakeMaterial.SetFloat("_ShakeTime", Time.time);
            yield return new WaitForSeconds(2f);
        }
        
    }
}
