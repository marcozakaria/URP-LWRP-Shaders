using System.Collections;
using UnityEngine;

public class AudioSyncherCamera : AudioSyncer
{
    [Header("Camera")]
    [SerializeField] CameraShake cameraShake;
    [SerializeField] Camera mainCamera;

    [Header("Camera Settings")]
    [SerializeField] Vector3 beatValue;
    [SerializeField] Vector3 restValue;

    private void Start()
    {
       // bias = 10;
    }

    public override void OnUpdate()
    {
        base.OnUpdate();

        if (m_isBeat) return;

        mainCamera.transform.position = restValue;
    }

    public override void OnBeat()
    {
        base.OnBeat();

        CameraFiledOfView();
        //CameraShake();
    }

    void CameraShake()
    {
        if (cameraShake.isShaking)
        {
            return;
        }

        cameraShake.ShakeIt();
    }

    void CameraFiledOfView()
    {
        StopCoroutine("MoveToValue");
        StartCoroutine("MoveToValue", beatValue);
    }

    private IEnumerator MoveToValue(Vector3 _target)
    {
        Vector3 _curr = transform.position;
        Vector3 _initial = _curr;
        float _timer = 0;

        while (_curr != _target)
        {
            _curr = Vector3.Lerp(_initial, _target, _timer / timeToBeat);
            _timer += Time.deltaTime;

            transform.position = _curr;

            yield return null;
        }

        m_isBeat = false;
    }
}
