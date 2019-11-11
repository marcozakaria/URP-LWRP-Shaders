using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioSyncherCamera : AudioSyncer
{
    private void Start()
    {
        bias = 10;
    }

    public override void OnUpdate()
    {
        base.OnUpdate();
    }

    public override void OnBeat()
    {
        base.OnBeat();
        CameraShake.instance.ShakeIt();
    }
}
