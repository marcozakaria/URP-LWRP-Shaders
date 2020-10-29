using System.Collections;
using UnityEngine;

public class MatrixJumpBetweenValues : MonoBehaviour
{
    [SerializeField] Vector2 waitTime = new Vector2(0.1f, 0.3f);
    private Material mat;

    void Start()
    {
        mat = GetComponent<SpriteRenderer>().material;
        StartCoroutine(StartGlitch());
    }

    IEnumerator StartGlitch()
    {
        float time;
        while (true)
        {
            time = 0;
            while (time < 0.1f)
            {
                mat.SetFloat("_NoiseLerp", Random.Range(-0.2f, 0.2f));
                time += Time.deltaTime;
                yield return null;
            }
            yield return new WaitForSeconds(Random.Range(waitTime.x, waitTime.y));
        }
    }
}
