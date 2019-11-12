using System.Collections;
using UnityEngine;

public class AudioSyncerTiling : AudioSyncer
{
    public Vector2 maxTiling;
    public Vector2 restTiling;
    private Material material;

    private void Start()
    {
        material = GetComponent<MeshRenderer>().material;
        bias = Random.Range(5, 50);
    }


    public override void OnUpdate()
    {
        base.OnUpdate();

        if (m_isBeat) return;
        //transform.localScale = Vector3.Lerp(transform.localScale, restScale, restSmoothTime * Time.deltaTime);
        // material.color = Color.Lerp(material.color, restColor, restSmoothTime * Time.deltaTime);
        material.mainTextureScale = Vector2.Lerp(material.GetTextureScale("_MainTex"), restTiling, restSmoothTime * Time.deltaTime);
       // material.SetTextureScale("_DetailAlbedoMap", Vector2.Lerp(material.GetTextureScale("_DetailAlbedoMap"), maxTiling, restSmoothTime * Time.deltaTime));
    }

    public override void OnBeat()
    {
        base.OnBeat();

        StopCoroutine("MoveToScale");
        StartCoroutine("MoveToScale", maxTiling);
    }

    private IEnumerator MoveToScale(Vector2 _target)
    {
        Vector2 _curr = material.GetTextureScale("_MainTex");
        Vector2 _initial = _curr;
        float _timer = 0;

        Debug.Log("out");
        while (_curr != _target)
        {
            _curr = Vector2.Lerp(_initial, _target, _timer / timeToBeat);
            _timer += Time.deltaTime;
            Debug.Log(_curr);
            material.SetTextureScale("_MainTex", _curr);


            yield return null;
        }

        m_isBeat = false;
    }
}
