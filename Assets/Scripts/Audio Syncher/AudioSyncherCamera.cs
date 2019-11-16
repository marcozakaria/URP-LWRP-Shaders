using System.Collections;
using UnityEngine;

public class AudioSyncherCamera : AudioSyncer
{
    [Header("Camera")]
    [SerializeField] CameraShake cameraShake;
    [SerializeField] Camera mainCamera;

    [Header("FOV")]
    [SerializeField] float beatValue;
    [SerializeField] float restValue;

    private void Start()
    {
        bias = 10;
    }

    public override void OnUpdate()
    {
        base.OnUpdate();

        if (m_isBeat) return;

        mainCamera.fieldOfView = restValue;
    }

    public override void OnBeat()
    {
        base.OnBeat();

        CameraFiledOfView();
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

    private IEnumerator MoveToValue(float _target)
    {
        float _curr = mainCamera.fieldOfView;
        float _initial = _curr;
        float _timer = 0;

        while (_curr != _target)
        {
            _curr = Mathf.Lerp(_initial, _target, _timer / timeToBeat);
            _timer += Time.deltaTime;

            mainCamera.fieldOfView = _curr;

            yield return null;
        }

        m_isBeat = false;
    }
}
