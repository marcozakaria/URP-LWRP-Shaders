using System.Collections;
using UnityEngine;

public class AudioSyncMatValue : AudioSyncer
{
    [Header("Material settings")]
    [SerializeField] string valueToChange;
    [SerializeField] float beatValue;
    [SerializeField] float restValue;

    private int m_randomIndx;
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

        material.SetFloat(valueToChange,Mathf.Lerp(material.GetFloat(valueToChange), restValue, restSmoothTime * Time.deltaTime));
    }

    public override void OnBeat()
    {
        base.OnBeat();

        StopCoroutine("MoveToValue");
        StartCoroutine("MoveToValue", beatValue);
    }

    private IEnumerator MoveToValue(float _target)
    {
        float _curr = material.GetFloat(valueToChange);
        float _initial = _curr;
        float _timer = 0;

        while (_curr != _target)
        {
            _curr = Mathf.Lerp(_initial, _target, _timer / timeToBeat);
            _timer += Time.deltaTime;

            material.SetFloat(valueToChange, _curr);

            yield return null;
        }

        m_isBeat = false;
    }
}
