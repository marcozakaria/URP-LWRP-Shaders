using UnityEngine;

public class SetTargetFrameRate : MonoBehaviour
{
    private void Awake()
    {
        Application.targetFrameRate = 60;
    }
}
